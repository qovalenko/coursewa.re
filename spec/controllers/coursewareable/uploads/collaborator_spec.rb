require 'spec_helper'

describe Coursewareable::UploadsController, :focus => true do
  include ActionDispatch::TestProcess

  let(:classroom) { Fabricate('coursewareable/classroom') }
  let(:collaboration) { Fabricate('coursewareable/collaboration',
                                  :classroom => classroom) }
  let(:collaborator) { collaboration.user }

  describe 'POST create' do

    let(:syllabus) { Fabricate('coursewareable/syllabus',
      :user => collaborator, :classroom => classroom) }

    context 'being logged in as collaborator' do
      before(:each) do
        @controller.send(:auto_login, collaborator)
        @request.host = "#{classroom.slug}.#{@request.host}"
        post :create, { :use_route => :coursewareable,
          :file => fixture_file_upload('/test.txt', 'text/plain'),
          :assetable_type => syllabus.class.name,
          :assetable_id => syllabus.id
        }
      end

      subject { JSON.parse(response.body) }

      its('first.last') { should eq(classroom.uploads.first.url) }

      context 'and assetable object is missing' do
        let(:syllabus) { classroom.build_syllabus }

        its(:keys) { should include('error') }
      end

      context 'with file uploads limits reached' do
        before(:all) do
          collaborator.plan.decrement(:allowed_space, 1.gigabyte)
        end

        its(:keys) { should include('error') }
      end
    end

  end

  describe 'DELETE :destroy' do
    let(:upload) { Fabricate('coursewareable/upload', :classroom => classroom,
                            :user => classroom.owner) }
    before(:each) do
      @controller.send(:auto_login, collaborator)
      @request.host = "#{classroom.slug}.#{@request.host}"
      delete(:destroy, :use_route => :coursewareable, :id => upload.id)
    end

    context 'being logged in as collaborator' do

      it do
        should redirect_to(dashboard_classroom_path)
        classroom.uploads.should be_empty
      end

      context 'upload is missing' do
        before(:all) { upload.destroy }

        it { should redirect_to('/404') }
      end
    end
  end

end