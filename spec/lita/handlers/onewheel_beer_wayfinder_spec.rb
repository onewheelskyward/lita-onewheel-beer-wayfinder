require 'spec_helper'

describe Lita::Handlers::OnewheelBeerWayfinder, lita_handler: true do
  it { is_expected.to route_command('wayfinder') }
  it { is_expected.to route_command('wayfinder 4') }
  it { is_expected.to route_command('wayfinder nitro') }
  it { is_expected.to route_command('wayfinder CASK') }
  it { is_expected.to route_command('wayfinder <$4') }
  it { is_expected.to route_command('wayfinder < $4') }
  it { is_expected.to route_command('wayfinder <=$4') }
  it { is_expected.to route_command('wayfinder <= $4') }
  it { is_expected.to route_command('wayfinder >4%') }
  it { is_expected.to route_command('wayfinder > 4%') }
  it { is_expected.to route_command('wayfinder >=4%') }
  it { is_expected.to route_command('wayfinder >= 4%') }
  it { is_expected.to route_command('wayfinderabvhigh') }
  it { is_expected.to route_command('wayfinderabvlow') }

  before do
    mock = File.open('spec/fixtures/wayfinder.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'wayfinder'
    expect(replies.last).to include('taps: 1) ANDECHS VOLLBIER HELLES LAGER')
  end

  it 'displays details for tap 4' do
    send_command 'wayfinder 4'
    expect(replies.last).to include('Wayfinder tap 4) WEIHENSTEPHAN HEFEWEISSEBIER GERMAN HEFEWEIZEN')
  end

  it 'doesn\'t explode on 1' do
    send_command 'wayfinder 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Wayfinder tap 1) ANDECHS VOLLBIER HELLES LAGER - Beautifully malty, immensely drinkable Bavarian lager, 4.8%, ')
  end

  it 'searches for ipa' do
    send_command 'wayfinder ipa'
    expect(replies.last).to include('Wayfinder tap 14) PFRIEM TRIPLE IPA')
  end

  it 'searches for abv >9%' do
    send_command 'wayfinder >9%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq('Wayfinder tap 10) EVIL TWIN BISCOTTI BREAK IMPERIAL STOUT - Pitch black and deep. Coffee, toffee, aged cherry and roast. A wonderful dessert., 11.5%, ')
    expect(replies[1]).to eq('Wayfinder tap 14) PFRIEM TRIPLE IPA - Three times the amount of hops and malt, brimming with flavors of peaches and cream, strawberries, ripe citrus., 10.5%, ')
  end

  it 'searches for abv > 9%' do
    send_command 'wayfinder > 9%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq('Wayfinder tap 10) EVIL TWIN BISCOTTI BREAK IMPERIAL STOUT - Pitch black and deep. Coffee, toffee, aged cherry and roast. A wonderful dessert., 11.5%, ')
    expect(replies[1]).to eq('Wayfinder tap 14) PFRIEM TRIPLE IPA - Three times the amount of hops and malt, brimming with flavors of peaches and cream, strawberries, ripe citrus., 10.5%, ')
  end

  it 'searches for abv >= 9%' do
    send_command 'wayfinder >= 9%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq('Wayfinder tap 10) EVIL TWIN BISCOTTI BREAK IMPERIAL STOUT - Pitch black and deep. Coffee, toffee, aged cherry and roast. A wonderful dessert., 11.5%, ')
    expect(replies.last).to eq('Wayfinder tap 14) PFRIEM TRIPLE IPA - Three times the amount of hops and malt, brimming with flavors of peaches and cream, strawberries, ripe citrus., 10.5%, ')
  end

  it 'runs a random beer through' do
    send_command 'wayfinder roulette'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Wayfinder tap')
  end

  it 'runs a random beer through' do
    send_command 'wayfinder random'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Wayfinder tap')
  end

  it 'searches with a space' do
    send_command 'wayfinder cider riot'
    expect(replies.last).to eq('Wayfinder tap 16) CIDER RIOT! EVERYBODY POGO HOPPED CIDER - Fantastic dry cider from our local buds., 6.7%, ')
  end

  it 'displays low abv' do
    send_command 'wayfinderabvhigh'
    expect(replies.last).to eq('Wayfinder tap 10) EVIL TWIN BISCOTTI BREAK IMPERIAL STOUT - Pitch black and deep. Coffee, toffee, aged cherry and roast. A wonderful dessert., 11.5%, ')
  end

  it 'displays high abv' do
    send_command 'wayfinderabvlow'
    expect(replies.last).to eq('Wayfinder tap 1) ANDECHS VOLLBIER HELLES LAGER - Beautifully malty, immensely drinkable Bavarian lager, 4.8%, ')
  end
end
