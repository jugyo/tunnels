require 'spec_helper'

# to stub
def EventMachine.run(&block)
  block.call
end

describe Tunnels do
  describe '.run!' do
    context 'with no args' do
      it 'works' do
        mock(EventMachine).start_server('127.0.0.1', 443, Tunnels::HttpsProxy, 80)
        Tunnels.run!
      end
    end

    context 'with args' do
      it 'works' do
        mock(EventMachine).start_server('127.0.0.1', 443, Tunnels::HttpsProxy, 80)
        Tunnels.run!('127.0.0.1:443', '127.0.0.1:80')
      end
    end
  end
end