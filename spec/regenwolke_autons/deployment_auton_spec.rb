module RegenwolkeAutons

  describe DeploymentAuton do

    let (:context) {spy :context}

    before do
      subject.context = context
    end

    describe '#start' do

      before do
        subject.start 'app1', 'some_sha'
      end

      it 'should store application name' do
        expect(subject.application_name).to eq('app1')
      end

      it 'should store git_sha1 and schedule :start_container' do
        expect(subject.git_sha1).to eq('some_sha')
      end

      it 'should schedule :start_container' do
        expect(context).to have_received(:schedule_step).with(:request_port)
      end

    end

    describe '#request_port' do
      it "should request port from port_manager" do
        expect(context).to receive(:auton_id).and_return('my_id')
        subject.request_port
        expect(context).to have_received(:schedule_step_on_auton).with('port_manager',:request_port, ['my_id', :use_port])
      end
    end

    describe '#use_port' do
      before do
        subject.use_port 123
      end

      it 'should store port' do
        expect(subject.port).to eq(123)
      end

      it 'should schedule :start_container' do
        expect(context).to have_received(:schedule_step).with(:start_container)
      end

    end

    describe '#start_container' do

      let(:docker_container) {spy :docker_container}

      before do
        subject.port = 123
        allow(Docker::Container).to receive(:create).and_return(docker_container)
        allow(docker_container).to receive(:id).and_return('docker_id')
        subject.start_container
      end

      it 'should start container' do
        expect(Docker::Container).to have_received(:create)
        expect(docker_container).to have_received(:start)
      end

      it 'should schedule :notify_application' do
        expect(context).to have_received(:schedule_step).with(:notify_application)
      end

      it 'should store container id' do
        expect(subject.container_id).to eq('docker_id')
      end

    end

    describe '#notify_application' do

      it "should schedule :deployment_complete step with sha1 of the deployment and port number on the application auton" do
        subject.port = 123
        subject.application_name = 'some_app'
        subject.git_sha1 = 'some_sha1'
        context = double :context
        subject.context = context

        expect(context).to receive(:schedule_step_on_auton).with("application:some_app", :deployment_complete, ['some_sha1', 123])

        subject.notify_application

      end
    end

  end


end
