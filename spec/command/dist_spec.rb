require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Dist do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ dist }).should.be.instance_of Command::Dist
      end
    end
  end
end

