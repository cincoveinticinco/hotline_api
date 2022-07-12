class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def encode_token_report(report)
    report.update(token_last_update: DateTime.now)
      payload = { id: report.id, reference: report.r_reference}
      JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end

end
