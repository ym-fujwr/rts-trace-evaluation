# 実験手順
## 前準備
1. repositories.txt に　プロジェクト名(任意) リポジトリのgithubURL 先頭のリビジョンID を記述
2. script/setup.shを実行 (先頭のリビジョンIDから遡り，javaファイルに変更のあったコミットIDを original_source
プロジェクト名/revisions.txt に記述
3. revisions.txtの１行目にIDが2つあるので改行して分ける
4. script/download.shを実行 (original_source/にプロジェクトの各リビジョンのリポジトリがクローンされる）

## 全テスト実行
1. script/runAll.sh の10行目を subN=プロジェクト名に 編集．(jitwatchの場合は，26行目をコメントアウト，28行目をアンコメント)
2. script/runAll.sh を実行

## Ekstazi実行
1. script/runEkstazi.sh の22行目を  subN=プロジェクト名に 編集
2. script/runEkstazi.sh 29~50行目を プロジェクトに合わせてコメントアウト/アンコメント
3. (jitwatchの場合) script/runEkstazi.sh 56行目をコメントアウト 57行目をアンコメント，60行目をコメントアウト 61行目をアンコメント，65行目をコメントアウト，66行目をアンコメント
4. script/runEkstazi.sh を実行

## rts-trace実行
1. plugins.txt に除くプラグインを記述．（memo.txtの100行目あたりから移してくる）
2. script/runRtsTrace.sh の40行目を subN=プロジェクト名に 編集
3. script/runRtsTrace.sh の96行目のfor文のループ範囲を，先頭と最後のリビジョン番号に合わせる
4. script/runRtsTrace.sh の100行目あたりをプロジェクトに合わせてコメントアウト/アンコメント
5. (NuProcessの場合） NuProcess用 の下の行をアンコメント
6. script/runRtsTrace.sh を実行
(jitwatchの場合は，script/runRtsTraceForjitwatch.shを実行）

## 結果まとめる
1. script/extractTest_CollectBuild.sh を実行
2. script/collectReduction.sh を実行

-------------------------------------------------------------------------
## フォルダ
- ALL: 全テスト実行結果
- Ekstazi: Ekstaziの適用結果
- accuracy: いらないフォルダ（精度の評価ミスってるやつ
- accuracy2: 精度の評価結果（変更後の依存関係からテストを選択するverのrts-traceを適用結果）．memo.txtに適用できていない変更のメモがある．
- accuracy_sub:　精度評価適用前の状態のバックアップ
- jitwatch: 各リビジョンのgitdiff.txtをいじっている（diff取った時のパスがデフォルトでは　a/core/src/... となるが，実装の都合上 coreの部分が邪魔なので取り除いている．
- original_source: 各プロジェクト，各リビジョンのリポジトリの状態がある
- result: いらないフォルダ（評価ミスってるやつ）
- result2: 評価結果をまとめてる．（testtimeはいらないやつ．testtime2が正しい）
- rts-trace: いらないフォルダ（ミスってるやつ）
- rts-trace2: rts-traceの適用結果．
- sample: いらないフォルダ
- script: スクリプトを置いている
- workingDir: いらないフォルダ


