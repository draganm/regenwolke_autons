
module RegenwolkeAutons

  describe RegenwolkeAuton do

    let (:context) {double :context}

    before do
      subject.context = context
    end

    describe '#deploy_application' do
      context 'when application does not exist' do
        it 'should create new application_auton and schedule deploy method on the application' do

          expect(context).to receive(:create_auton).with("RegenwolkeAutons::ApplicationAuton", "application:app1")
          expect(context).to receive(:schedule_step).with('application:app1', :deploy, ['some_sha1'])

          subject.deploy_application('app1','some_sha1')

        end
      end

      context 'when application already exists' do

        before do
          subject.applications << 'app1'
        end

        it 'should schedule deploy method on the application' do
          expect(context).to receive(:schedule_step).with('application:app1', :deploy, ['some_sha1'])
          subject.deploy_application('app1','some_sha1')
        end
      end
    end
  end
end
