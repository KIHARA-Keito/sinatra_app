# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'uri'

MEMO_FILE_NAME = 'memo.json'

helpers do
  def escape_text(text)
    Rack::Utils.escape_html(text)
  end

  def read_memo(file_name)
    File.open(file_name, 'r') { |file| JSON.parse(file.read) }
  end

  def write_memo(file_name, memo)
    File.open(file_name, 'w') { |file| JSON.dump(memo, file) }
  end

  def generate_id
    random_number = SecureRandom.random_number(999).to_s.rjust(5, '0')
    "#{Time.now.to_i}#{random_number}"
  end

  def decode_and_hash(request)
    Hash[URI.decode_www_form(request)]
  end

  def post_has_empty(post_data)
    return unless post_data['title'].empty? || post_data['body'].empty?

    redirect '/error'
    exit
  end
end

get '/' do
  @title = 'メモ一覧'
  @file = read_memo(MEMO_FILE_NAME)
  erb :index
end

get '/new' do
  @title = 'メモ追加'
  erb :new
end

post '/memo' do
  post_data = decode_and_hash(request.body.read)
  post_has_empty(post_data)
  id = generate_id
  memo_data = read_memo(MEMO_FILE_NAME)
  memo_data[id] = { 'title' => escape_text(post_data['title']).to_s, 'body' => escape_text(post_data['body']).to_s }
  write_memo(MEMO_FILE_NAME, memo_data)
  redirect '/'
end

get '/memo/*/edit' do |id|
  @id = id
  @title = 'メモ編集'
  @file = read_memo(MEMO_FILE_NAME)
  erb :edit
end

get '/memo/*' do |id|
  @id = id
  @title = 'メモ詳細'
  @file = read_memo(MEMO_FILE_NAME)
  erb :memo
end

patch '/memo/*' do |id|
  post_data = decode_and_hash(request.body.read)
  post_has_empty(post_data)
  memo_data = read_memo(MEMO_FILE_NAME)
  memo_data[id] = { 'title' => escape_text(post_data['title']).to_s, 'body' => escape_text(post_data['body']).to_s }
  write_memo(MEMO_FILE_NAME, memo_data)
  redirect '/'
end

delete '/memo/*' do |id|
  memo_data = read_memo(MEMO_FILE_NAME)
  memo_data.delete(id)
  write_memo(MEMO_FILE_NAME, memo_data)
  redirect '/'
end

get '/error' do
  @title = 'タイトルと内容を両方入力してください'
  erb :error
end