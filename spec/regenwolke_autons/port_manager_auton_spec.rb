module RegenwolkeAutons

  describe PortManagerAuton do

    let (:context) {spy :context}

    before do
      subject.context = context
    end

    describe '#start' do
      it "should allocate 50 ports" do
        subject.start
        expect(subject.free_ports.size).to be(50)
        expect(subject.used_ports.size).to be(0)
      end
    end

    describe '#release_port' do
      before do
        subject.start
        @first_port = subject.free_ports.first
        subject.request_port('some_id', 'some_method')
      end

      it 'should remove port from the used_ports' do
        subject.release_port('some_id', @first_port)
        expect(subject.used_ports).to eq({})
      end


      it 'should return port to the list of free ports' do
        subject.release_port('some_id', @first_port)
        expect(subject.free_ports.last).to eq(@first_port)
      end

    end

    describe '#request_port' do
      before do
        subject.start
        @first_port = subject.free_ports.first
        subject.request_port('some_id', 'some_method')
      end

      it "should schedule method with the port on the specified auton_id" do
        expect(context).to have_received(:schedule_step_on_auton).with('some_id','some_method',[@first_port])
      end

      it 'should remove first port from the free ports' do
        expect(subject.free_ports.size).to eq(49)
      end

      it 'should add port allocation to used_ports' do
        expect(subject.used_ports).to eq({"some_id"=>[@first_port]})
      end

    end

  end
end
