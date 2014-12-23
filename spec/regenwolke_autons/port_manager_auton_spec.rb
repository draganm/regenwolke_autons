module RegenwolkeAutons

  describe PortManagerAuton do

    let (:context) {double :context}

    before do
      subject.context = context
    end

    describe '#start' do
      it "allocates 50 ports" do

        subject.start
        expect(subject.free_ports.size).to be(50)
        expect(subject.used_ports.size).to be(0)
      end
    end

  end
end
