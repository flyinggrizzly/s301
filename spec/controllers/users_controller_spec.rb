require 'rails_helper'

RSpec.describe UsersController do
  # Behavior changed from Clearance defaults to include confirmations
  describe '#create' do
    context 'with valid attributes' do
      it 'creates a user and sends a confirmation email' do
        email = 'anewuser@bar.org'

        post :create, params: { user: { email: email, password: 'goofballgoofball' } }

        expect(controller.current_user).to be_nil
        expect(last_email_confirmation_token).to be_present
        should_deliver_email(email:   email,
                             subject: t('email.subject.confirm_email'))
      end
    end
  end

  private

  def should_deliver_email(to:, subject:)
    expect(ActionMailer::Base.deliveries).not_to be_empty

    email = ActionMailer::Base.deliveries.last
    expect(email).to deliver_to(to)
    expect(email).to have_subject(subject)
  end

  def last_confirmation_token
    User.last.email_confirmation_token
  end
end
