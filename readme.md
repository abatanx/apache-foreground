# Foreground apache
Foreground で apache を実行するスクリプト。
仮想環境とか Docker とかいろいろめんどくさいので、brew の環境で使えるざっくりしたものです。
built-in Serverでは使えない `.htaccess` を使用したいときなどに使います.

## 使い方
1. 任意のディレクトリにクローン
2. `config.example.conf` をコピーして `config.conf` を作成
3. `config.conf` に設定を記述 (記法は後述)
4. `apache.sh` を実行

## 終わらせ方
ctrl + c で終了.  
これをしないとkillコマンドで殺すまで動くので __注意__
なんかおかしいときは、ぐるぐるまわる手抜き仕様なので __注意__
### `config.conf` の設定
* **SERVER_NAME**  
ローカルホストのIPやテストドメインなど設定
* **SERVER_PORT**  
ポートを指定(Wellknown Port の場合は、当然 root 必要です。)
* **DOCUMENT_ROOT**  
ドキュメントルートのパスを記述(相対パスのときは `apache.sh` からの位置)
* **PHP_MODULE_PATH**  
PHPのモジュールのパスを記載
* **PHP_INCLUDE_PATH**  
起動時に読み込むPHPのパスを記載(php の `include_path` の値と同様の形式)
* **XDEBUG**  
2 / 3 を指定してください
* **XDEBUG_REMOTE_HOST**  
PHPからのXdebug接続リモートホストアドレス(いわゆるXdebug対応のIDEを起動しているPC)を指定してください。だいたい localhost とか、127.0.0.1 じゃないですかね。
* **XDEBUG_REMOTE_PORT**  
IDE側で待ち受け設定している Xdebug のポート番号を指定してください。
* **XDEBUG_IDEKEY**  
IDE側で待ち受け設定している Xdebug のIDEKEYを指定してください。
