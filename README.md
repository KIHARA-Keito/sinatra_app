# sinatra_app

postgresql 使用のメモアプリです。
clone して対象フォルダに移動後、以下を実行すればローカルにて動作確認いただけます。

## gem のインストール

```
$ bundle install
```

## postgresql での DDL 実行（.sql ファイル）

### DB・TABLE 作成

```
# ログイン
$ psql -U {ユーザー名} {既存のデータベース名}

# ログイン（例）
$ psql -U user01 postgres

# DB作成
postgres=# \i ddl_db.sql

# いったんログアウト
postgres=# \q

# 作成したデータベースにログイン
$ psql -U user01 memo_list

# TABLE作成
memo_list=# \i ddl_table.sql

# 確認
memo_list=# \d Memo
memo_list=# select * from memo;
```

### DB 設定ファイル作成

.env ファイルを作成して、DB 接続情報を記載してください

```.env
DATABASE_USER='ユーザー名'
DATABASE_PASSWORD='パスワード'
DATABASE_NAME='データベース名'
```

## アプリケーション起動

```
$ bundle exec ruby app.rb
```

下記にアクセスで表示されます。

http://localhost:4567/

## スクリーンショット

<img src="https://github.com/KIHARA-Keito/sinatra_app/assets/1395068/15c10acb-edac-49f4-8e88-fdc632a4cf42" width="50%" />
<img src="https://github.com/KIHARA-Keito/sinatra_app/assets/1395068/0f25597b-5fc2-41c6-83f0-8ef4a10ccae2" width="50%" />
<img src="https://github.com/KIHARA-Keito/sinatra_app/assets/1395068/b947ad17-a919-48ca-8df0-42c1f68d1bb4" width="50%" />
<img src="https://github.com/KIHARA-Keito/sinatra_app/assets/1395068/8e71f889-7dab-45cf-a2c4-4a3d8bb469cf" width="50%" />
<img src="https://github.com/KIHARA-Keito/sinatra_app/assets/1395068/3ced6136-3854-43b3-a097-c96515c68354" width="50%" />
<img src="https://github.com/KIHARA-Keito/sinatra_app/assets/1395068/243456cd-1dcd-4322-a232-65fc699f0b4e" width="50%" />
