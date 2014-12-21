module RegenwolkeAutons

  describe ApplicationAuton do

    let (:context) {double :context}

    before do
      subject.context = context
      subject.application_name = 'app1'
    end

    describe '#deploy' do

      it 'should start a new deployment process' do
        expect(context).to receive(:create_auton).with('RegenwolkeAutons::DeploymentAuton', 'deployment:app1:some_sha')
        expect(context).to receive(:schedule_step_on_auton).with('deployment:app1:some_sha', :start, ['app1','some_sha'])
        subject.deploy('some_sha')

      end

    end

    describe '#deployment_complete' do
      context 'when there is not running deployment' do
        it 'should change endpoints on nginx' do

          expect(context).to receive(:schedule_step_on_auton).with("nginx", :update_endpoints, [{"app1"=>123}, {}])

          subject.deployment_complete('some_sha',123)
        end
      end

      context 'when there is already a running deployment' do

        before do
          subject.current_deployment = CurrentDeployment.new
          subject.current_deployment.git_sha1 = 'old_sha'
          subject.current_deployment.port = 333
        end

        it 'should change endpoints on nginx and terminate existing deployment' do

          expect(context).to receive(:schedule_step_on_auton).with("nginx", :update_endpoints, [{"app1"=>123}, {"app1"=>333}])
          expect(context).to receive(:schedule_step_on_auton).with("deployment:app1:old_sha", :terminate)

          subject.deployment_complete('some_sha',123)
        end
      end

    end

  end
end
