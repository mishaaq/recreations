require 'spec_helper'

RSpec.describe "Recreations::Reservations::ReservationHelper" do
  pending "add some examples to (or delete) #{__FILE__}" do
    let(:helpers){ Class.new }
    before { helpers.extend Recreations::Reservations::ReservationHelper }
    subject { helpers }

    it "should return nil" do
      expect(subject.foo).to be_nil
    end
  end
end
