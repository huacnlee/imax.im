# 验证是不是 API 的域名
class MainDomainMatcher
  def self.matches?(request)
    not request.host.include?('imax-api')
  end
end