require 'twitter_ebooks'
require 'dotenv'

if File.file?(".env")
  Dotenv.load(".env")
end

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
    scheduler.cron '0 0,6,12,18 * * *' do
      model = Ebooks::Model.load("model/label.model")
      tweet(model.make_statement(140))
    end
  end

  def on_mention(tweet)
    model = Ebooks::Model.load("model/label.model")

    top100 = model.keywords.take(100)
    tokens = Ebooks::NLP.tokenize(tweet.text)
    interesting = tokens.find { |t| top100.include?(t.downcase) }

    if interesting
      favorite(tweet)
    end

    reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
  end

end

MyBot.new("bronnerbot") do |bot|
  bot.access_token = OAUTH_TOKEN
  bot.access_token_secret = OAUTH_TOKEN_SECRET
end
