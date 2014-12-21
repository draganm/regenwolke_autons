require 'regenwolke_autons'
module RegenwolkeAutons

  describe NginxAuton do

    let(:context) {double :context}

    before do
      subject.context = context
    end


    describe '#start_nginx' do
      it 'should create config, tests config, starts nginx and waits for nginx to start' do

        expect(subject).to receive(:create_config)
        expect(subject).to receive(:system).with('nginx','-t','-p', 'regenwolke/nginx', '-c', 'nginx.config').and_return(true)
        expect(subject).to receive(:system).with('nginx','-p', 'regenwolke/nginx', '-c', 'nginx.config').and_return(true)
        expect(subject).to receive(:wait_for_nginx)

        subject.start_nginx
      end

      context 'when config test fails' do
        it 'should raise exception' do
          expect(subject).to receive(:create_config)
          expect(subject).to receive(:system).with('nginx','-t','-p', 'regenwolke/nginx', '-c', 'nginx.config').and_return(false)
          expect {subject.start_nginx}.to raise_error('Invalid nginx config')
        end
      end

      context 'when nginx start fails' do
        it 'should raise exception' do
          expect(subject).to receive(:create_config)
          expect(subject).to receive(:system).with('nginx','-t','-p', 'regenwolke/nginx', '-c', 'nginx.config').and_return(true)
          expect(subject).to receive(:system).with('nginx','-p', 'regenwolke/nginx', '-c', 'nginx.config').and_return(false)
          expect {subject.start_nginx}.to raise_error('Could not start nginx')
        end
      end
    end

    describe '#start_nginx_if_not_running' do
      context 'when nginx is not running' do
        it 'should schedule :start_nginx' do
          expect(subject).to receive(:nginx_running?).and_return(false)
          expect(context).to receive(:schedule_step).with(:start_nginx)
          subject.start_nginx_if_not_running
        end
      end

      context 'when nginx is running' do
        it 'should not schedule :start_nginx' do
          expect(subject).to receive(:nginx_running?).and_return(true)
          expect(context).not_to receive(:schedule_step).with(:start_nginx)
          subject.start_nginx_if_not_running
        end
      end

    end

    describe '#wait_for_nginx' do
      context 'when nginx is running' do

        it 'should terminate immediately' do
          expect(subject).to receive(:nginx_running?).and_return(true)
          subject.send(:wait_for_nginx)
        end

      end

      context 'when nginx is not running immediately' do

        context 'when nginx is running on the second check' do

          it 'should sleep for 0.1 seconds and terminate' do
            expect(subject).to receive(:nginx_running?).and_return(false, true)
            expect(subject).to receive(:sleep).with(0.1)
            subject.send(:wait_for_nginx)
          end

        end

      end

      context 'when nginx is not running after 20 checks' do

        it 'should raise an error' do
          expect(subject).to receive(:nginx_running?).and_return(false).exactly(20).times
          expect(subject).to receive(:sleep).with(0.1).exactly(20).times
          expect{ subject.send(:wait_for_nginx) }.to raise_error("nginx didn't start within 20 seconds")
        end

      end

    end


  end
end