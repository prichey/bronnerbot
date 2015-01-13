require 'twitter_ebooks'
require 'dotenv'

Dotenv.load(".env")

CONSUMER_KEY = ENV['EBOOKS_CONSUMER_KEY']
CONSUMER_SECRET = ENV['EBOOKS_CONSUMER_SECRET']
OAUTH_TOKEN = ENV['EBOOKS_OAUTH_TOKEN']
OAUTH_TOKEN_SECRET = ENV['EBOOKS_OAUTH_TOKEN_SECRET']

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  def configure
    self.consumer_key = CONSUMER_KEY
    self.consumer_secret = CONSUMER_SECRET

    # Users to block instead of interacting with
    self.blacklist = ['DrBronner']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def on_startup
    scheduler.every '1h' do
      model = Ebooks::Model.load("model/label.model")
      tweet(model.make_statement(140))
    end

    scheduler.every '12h' do
      model = Ebooks::Model.load("model/label.model")
      bot.twitter.search("Dr. Bronner's", result_type: "recent").take(10).each do |tweet|
        tweeter = meta(tweet).reply_prefix
        reply_content = meta(tweet).mentionless
        response = model.make_response(reply_content, 140 - tweeter.length + 2)
        reply(tweet, tweeter + response)
      end
    end
  end

  def on_message(dm)
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    # follow(user.screen_name)
  end

  def on_mention(tweet)
    model = Ebooks::Model.load("model/label.model")
    tweeter = meta(tweet).reply_prefix
    reply_content = meta(tweet).mentionless
    response = model.make_response(reply_content, 140 - tweeter.length + 2)
    reply(tweet, tweeter + response)
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end
end

# Make a MyBot and attach it to an account
MyBot.new("bronnerbot") do |bot|
  bot.access_token = OAUTH_TOKEN
  bot.access_token_secret = OAUTH_TOKEN_SECRET
end
