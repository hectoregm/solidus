require 'spec_helper'

describe Spree::AppConfiguration, type: :model do
  let(:prefs) { Rails.application.config.spree.preferences }

  it "should be available from the environment" do
    prefs.layout = "my/layout"
    expect(prefs.layout).to eq "my/layout"
  end

  it "should be available as Spree::Config for legacy access" do
    expect(Spree::Config).to be_a Spree::AppConfiguration
  end

  it "uses base searcher class by default" do
    expect(prefs.searcher_class).to eq Spree::Core::Search::Base
  end

  it "uses variant search class by default" do
    expect(prefs.variant_search_class).to eq Spree::Core::Search::Variant
  end

  it "uses variant pricer class by default" do
    expect(prefs.variant_pricer_class).to eq Spree::Variant::Pricer
  end

  it "has a getter for the pricing options class provided by the variant pricer class" do
    expect(prefs.pricing_options_class).to eq Spree::Variant::Pricer.pricing_options_class
  end

  it "has an instacached getter for the default pricing options" do
    expect(prefs.default_pricing_options).to be_a Spree::Variant::Pricer.pricing_options_class
    expect(prefs.default_pricing_options.object_id).to eq prefs.default_pricing_options.object_id
  end

  describe '#stock' do
    subject { prefs.stock }
    it { is_expected.to be_a Spree::Core::StockConfiguration }
  end

  describe '@default_country_iso_code' do
    it 'is the USA by default' do
      expect(prefs[:default_country_iso]).to eq("US")
    end
  end

  describe '@admin_vat_country_iso' do
    it 'is `nil` by default' do
      expect(prefs[:admin_vat_country_iso]).to eq(nil)
    end
  end

  it 'has a default admin VAT location with nil values by default' do
    expect(prefs.admin_vat_location).to eq(Spree::Tax::TaxLocation.new)
    expect(prefs.admin_vat_location.state_id).to eq(nil)
    expect(prefs.admin_vat_location.country_id).to eq(nil)
  end
end
