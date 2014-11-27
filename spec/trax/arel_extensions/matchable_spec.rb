require 'spec_helper'
describe ::ArelExtensions::Matchable do
  let(:product) { ::Product.create(:name => "27 inch iMac") }
  subject{ product }

  describe ".matching" do
    it('does a like lookup') do
      Product.matching(:name => "imac").to_sql.should include("LIKE '%imac%'")
    end

    ["imac", "ima", "INCH IMAC", "27"].each do |keyword|
      it "#{keyword} should return match" do
         Product.matching(:name => keyword).should include subject
      end
    end
  end
end
