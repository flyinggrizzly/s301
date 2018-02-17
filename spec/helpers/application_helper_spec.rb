require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#full_title' do
    around :each do |ex|
      app_name = S301::Application.config.app_name
      S301::Application.config.app_name = 'APP TITLE'
      ex.run
      S301::Application.config.app_name = app_name
    end

    context 'when provided a title param' do
      it 'returns a title including the application title' do
        expect(full_title('Parameter for Title')).to eq('APP TITLE | Parameter for Title')
      end
    end

    context 'when provided no params' do
      it 'returns a title that is equal to the application title' do
        expect(full_title).to eq('APP TITLE')
      end
    end
  end
end
