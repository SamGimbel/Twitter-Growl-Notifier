require 'rubygems'
require 'twitter'
# ruby-growl requires you to set up growl to allow remote requests.  v2 will use the Growl SDK
require 'ruby-growl'

class GrowlMention < Twitter::Client
  
  # future plans to store verification data as a YAML file
  #def OAuthConfig STORE AS YAML
   # f = File.open('config.rb')
    #a = f.readlines
    #end
    
    OAuthToken = {:consumer_key => "xxxx",
                  :consumer_secret => "xxxx",
                  :oauth_token => "xxxx",
                  :oauth_secret => "xxxx"}
  
  def initialize
    @displayed_mentions = {}
  end
  
  def authenticate
    Twitter.configure do |config|
      config.consumer_key = OAuthToken[:consumer_key]
      config.consumer_secret = OAuthToken[:consumer_secret]
      config.oauth_token = OAuthToken[:oauth_token]
      config.oauth_token_secret = OAuthToken[:oauth_secret]
    end
  end
  
  def notify(message)
    g = Growl.new "localhost", "ruby-growl",
                  ["ruby-growl Notification"]
    g.notify "ruby-growl Notification", "New Mention",
             "#{message}"
  end
  
  def latest_mentions
    mentions = Twitter.mentions(options = {:count => 10})
    mentions.reject!{|mention| 
      @displayed_mentions[mention['id']] 
    }
    mentions.each {|mention| @displayed_mentions[mention['id']] = true}
    puts "found #{mentions.count} new mentions"
    mentions
  end  
  
  def get_message_from_mention(hash)
    hash['user']['screen_name'] + ": " + hash['text']
  end
  
  def process
    mentions = latest_mentions
    mentions.each {|mention| notify(get_message_from_mention(mention))}    
  end
  
end
  
  poller = fork do
    user = GrowlMention.new
    user.authenticate    
    loop do
      user.process
      sleep 30
    end
  end
  