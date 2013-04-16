Session.ensure_index(:login_token)
Template.ensure_index(:name)
User.ensure_index([[:name, 1], [:email, 1]])