BAIDU_SITE = 'https://openapi.baidu.com'
BAIDU_USER_PATH = '/rest/2.0/passport/users/getLoggedInUser'

BAIDU_CLIENT = OAuth2::Client.new('3BaTp8XNScfi9M98bFeItE4M',
                                  'jn6USVGSzisEmWsYloDgsrZl1PEaqCdZ',
                                  :site => BAIDU_SITE,
                                  :authorize_url => '/oauth/2.0/authorize',
                                  :token_url => '/oauth/2.0/token'
)

YOUKU_SITE = 'https://openapi.youku.com'
YOUKU_USER_PATH = '/v2/users/myinfo.json'
YOUKU_CLIENT_ID = 'dcc429c4a3572d8f'

YOUKU_CLIENT = OAuth2::Client.new(YOUKU_CLIENT_ID,
                                  '702903f8ea9cd04fbb4665e6cae7d258',
                                  :site => YOUKU_SITE,
                                  :authorize_url => '/v2/oauth2/authorize',
                                  :token_url => '/v2/oauth2/token'
)