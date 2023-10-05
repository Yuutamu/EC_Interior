# API_version 最新のものに修正. 参考:（https://stripe.com/docs/api/versioning?lang=ruby）
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
Stripe.api_version = '2023-08-16'