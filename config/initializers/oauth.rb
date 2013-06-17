BAIDU_ROOT_FOLDER = '/apps/云酷'

BAIDU_SITE = 'https://openapi.baidu.com'
BAIDU_USER_PATH = '/rest/2.0/passport/users/getLoggedInUser'

BAIDU_PCS_SITE = 'https://pcs.baidu.com'
BAIDU_FILES = '/rest/2.0/pcs/file'

BAIDU_CLIENT = OAuth2::Client.new('0WFIfkgnmrMSBjwC7nL4OYGZ',
                                  'xn6jS7Wyowf5BzMvr9ktm2dlPskXTxRG',
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

MINGP_SITE = 'http://namecard.sctab.com'
MINGP_CLIENT_ID = '5192f6956b04f76e39000085'
MINGP_USER_INFO = '/api/user_info.json'
MINGP_P_USER_INFO = '/public/user_info'

MINGP_CLIENT = OAuth2::Client.new(MINGP_CLIENT_ID,
                                  '2ce1dce650972b55fbe5755373666c009387a71f24a5d842037ff75afc856dd0',
                                  :site => MINGP_SITE,
                                  :token_url => '/oauth/access_token')

