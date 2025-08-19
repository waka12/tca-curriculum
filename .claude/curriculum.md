# TCA 実践学習カリキュラム - 8週間プログラム

## 環境設定
```swift
// Package.swift または Xcode Package Dependencies
dependencies: [
  .package(
    url: "https://github.com/pointfreeco/swift-composable-architecture",
    from: "1.20.2"  // 2025年8月最新版
  )
]
```

### 必要環境
- **Xcode**: 16.0以上
- **Swift**: 6.0以上（Swift 5.9も互換性あり）
- **iOS**: 17.0以上
- **TCA**: 1.20.2以上

### 最新版TCAの主要な書き方
```swift
// Reducerの定義（@Reducerマクロを使用）
@Reducer
struct CounterFeature {
    @ObservableState  // @Stateではなく@ObservableState
    struct State: Equatable {
        var count = 0
    }
    
    enum Action {
        case incrementButtonTapped
        case decrementButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none
            case .decrementButtonTapped:
                state.count -= 1
                return .none
            }
        }
    }
}

// Viewの定義（WithViewStoreは基本不要）
struct CounterView: View {
    @Bindable var store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack {
            Text("\(store.count)")
            Button("＋") { store.send(.incrementButtonTapped) }
            Button("−") { store.send(.decrementButtonTapped) }
        }
    }
}
```

## カリキュラム概要
- **期間**: 8週間（週5日、1日2-3時間想定）
- **形式**: 実装課題 → セルフチェック → レビュー依頼
- **目標**: 実務でTCAを自信を持って使えるレベルに到達

---

## 📚 Week 1: TCA基礎 - シンプルな状態管理

### Day 1: Counter App
**課題**: カウンターアプリを実装
- 要件:
  - [ ] カウントの増減ボタン
  - [ ] リセットボタン
  - [ ] カウントの2倍を表示するラベル（computed property）
- 学習ポイント: State, Action, Reducer の基本

**セルフチェック**:
- [ ] Stateは最小限のプロパティか？
- [ ] Actionの命名は明確か？
- [ ] Reducerはpureか？

### Day 2: Counter with History
**課題**: Day1のアプリに履歴機能を追加
- 要件:
  - [ ] 過去5回の操作履歴を表示
  - [ ] 履歴をクリアする機能
- 学習ポイント: Stateの配列管理

### Day 3: Todo App (基本)
**課題**: シンプルなTodoアプリ
- 要件:
  - [ ] Todo追加（テキスト入力）
  - [ ] Todo削除（スワイプ）
  - [ ] 完了/未完了の切り替え
- 学習ポイント: IdentifiedArray, ForEachStore

### Day 4: Todo with Filter
**課題**: フィルター機能を追加
- 要件:
  - [ ] All/Active/Completedの切り替え
  - [ ] フィルター状態の保持
  - [ ] カウント表示
- 学習ポイント: computed propertyの活用

### Day 5: Week 1 統合課題
**課題**: メモアプリ（Todo + Counter の応用）
- 要件:
  - [ ] メモの作成/編集/削除
  - [ ] 文字数カウント表示
  - [ ] 作成日時の表示
  - [ ] メモの並び替え（作成日時/更新日時）

**レビュー依頼**: 
```
「Week 1の統合課題を完成させました。基本的なTCAの使い方についてレビューをお願いします。Level 1で」
```

---

## 📚 Week 2: 非同期処理とEffect

### Day 6: Timer App
**課題**: タイマーアプリ
- 要件:
  - [ ] スタート/ストップ/リセット
  - [ ] 1秒ごとのカウントアップ
  - [ ] バックグラウンドでも動作継続
- 学習ポイント: Effect, Timer, Cancellation

### Day 7: API Client (Mock)
**課題**: モックAPIを使った天気アプリ
- 要件:
  - [ ] 天気データの取得（2秒遅延のモック）
  - [ ] ローディング表示
  - [ ] エラーハンドリング
  - [ ] リトライ機能
- 学習ポイント: Task, Error handling

### Day 8: Search with Debounce
**課題**: インクリメンタルサーチ
- 要件:
  - [ ] テキスト入力から500ms後に検索実行
  - [ ] 連続入力時は前の検索をキャンセル
  - [ ] 検索中の表示
- 学習ポイント: Debounce, Cancel

### Day 9: Parallel Effects
**課題**: 複数API同時呼び出し
- 要件:
  - [ ] 3つの異なるAPIを同時に呼ぶ
  - [ ] 全て成功したら結果表示
  - [ ] 1つでも失敗したらエラー表示
  - [ ] 個別のローディング状態
- 学習ポイント: Effect.merge, Effect.concatenate

### Day 10: Week 2 統合課題
**課題**: GitHub リポジトリ検索アプリ
- 要件:
  - [ ] キーワード検索（debounce付き）
  - [ ] 検索結果の表示
  - [ ] お気に入り登録（ローカル保存）
  - [ ] 検索履歴の保存
  - [ ] ページネーション

**レビュー依頼**: 
```
「Week 2の統合課題を完成させました。Effect周りの実装について重点的にレビューをお願いします。」
```

---

## 📚 Week 3: Dependencies と テスト

### Day 11: Dependency Injection
**課題**: Day 7のアプリをDependency化
- 要件:
  - [ ] APIClientをDependencyとして定義
  - [ ] LiveValueとTestValueの実装
  - [ ] Previewでの動作確認
- 学習ポイント: @Dependency, DependencyValues

### Day 12: UserDefaults Dependency
**課題**: 設定画面の実装
- 要件:
  - [ ] UserDefaultsをDependencyでラップ
  - [ ] テーマ切り替え（Dark/Light）
  - [ ] 通知設定のON/OFF
  - [ ] 設定の永続化
- 学習ポイント: Persistence

### Day 13: Test Writing (基礎)
**課題**: Day 1-3のアプリにテストを追加
- 要件:
  - [ ] 各Actionに対するテスト
  - [ ] 初期状態のテスト
  - [ ] エッジケースのテスト
- 学習ポイント: TestStore, assertion

### Day 14: Test Writing (非同期)
**課題**: Day 6-8のアプリにテストを追加
- 要件:
  - [ ] 非同期処理のテスト
  - [ ] Effectのキャンセルテスト
  - [ ] エラーケースのテスト
- 学習ポイント: withExhaustivity, clock

### Day 15: Week 3 統合課題
**課題**: ログイン機能（完全テスト付き）
- 要件:
  - [ ] メールとパスワードの入力
  - [ ] バリデーション
  - [ ] ログインAPI（モック）
  - [ ] トークンの保存
  - [ ] 自動ログアウト（タイマー）
  - [ ] 全機能のテストカバレッジ80%以上

**レビュー依頼**: 
```
「Week 3の統合課題を完成させました。Dependencyの設計とテストの網羅性についてLevel 2でレビューをお願いします。」
```

---

## 📚 Week 4: Navigation と Composition

### Day 16: Navigation Stack
**課題**: 3階層のナビゲーション
- 要件:
  - [ ] List → Detail → Edit の画面遷移
  - [ ] 各画面でのデータ受け渡し
  - [ ] Deep Link対応
- 学習ポイント: @Presents, .destination, NavigationStack

### Day 17: Tab + Navigation
**課題**: タブ付きアプリ
- 要件:
  - [ ] 3つのタブ
  - [ ] 各タブ内でNavigation
  - [ ] タブ間でのデータ共有
- 学習ポイント: Scope, @Shared

### Day 18: Modal Presentation
**課題**: モーダル表示の実装
- 要件:
  - [ ] フルスクリーンモーダル
  - [ ] シート表示
  - [ ] Alert/Confirmation
  - [ ] 複数モーダルの管理
- 学習ポイント: @PresentationState, .sheet, .alert

### Day 19: Parent-Child Communication
**課題**: 親子Feature間の通信
- 要件:
  - [ ] 子から親への通知（Delegate Action）
  - [ ] 親から子へのデータ伝達
  - [ ] 兄弟Feature間の通信
- 学習ポイント: Delegate pattern

### Day 20: Week 4 統合課題
**課題**: Slack風チャットアプリ（UI部分）
- 要件:
  - [ ] チャンネル一覧（Tab 1）
  - [ ] DM一覧（Tab 2）
  - [ ] 設定（Tab 3）
  - [ ] チャンネル → メッセージ一覧 → メッセージ詳細
  - [ ] 新規メッセージ作成（モーダル）
  - [ ] メンション通知（Alert）

**レビュー依頼**: 
```
「Week 4の統合課題を完成させました。Navigation構造とFeatureの分割についてレビューをお願いします。」
```

---

## 📚 Week 5: 実践的なパターン

### Day 21: Form Validation
**課題**: ユーザー登録フォーム
- 要件:
  - [ ] リアルタイムバリデーション
  - [ ] 相互依存するフィールド
  - [ ] エラーメッセージ表示
  - [ ] Submit時の全体検証
- 学習ポイント: FormState, Validation

### Day 22: Pagination
**課題**: 無限スクロールリスト
- 要件:
  - [ ] 最下部到達で次ページ読み込み
  - [ ] ローディング表示
  - [ ] エラー時のリトライ
  - [ ] Pull to Refresh
- 学習ポイント: Pagination pattern

### Day 23: Cache Implementation
**課題**: キャッシュ機能付きアプリ
- 要件:
  - [ ] メモリキャッシュ
  - [ ] キャッシュの有効期限
  - [ ] キャッシュクリア
  - [ ] オフライン対応
- 学習ポイント: Cache strategy

### Day 24: Optimistic Update
**課題**: 楽観的更新の実装
- 要件:
  - [ ] 即座にUIを更新
  - [ ] バックグラウンドでAPI実行
  - [ ] 失敗時のロールバック
  - [ ] 競合状態の処理
- 学習ポイント: Optimistic UI

### Day 25: Week 5 統合課題
**課題**: Instagram風フィードアプリ
- 要件:
  - [ ] 投稿一覧（無限スクロール）
  - [ ] いいね機能（楽観的更新）
  - [ ] コメント投稿
  - [ ] 画像キャッシュ
  - [ ] オフライン時の動作

**レビュー依頼**: 
```
「Week 5の統合課題を完成させました。パフォーマンスとUXの観点からLevel 2でレビューをお願いします。」
```

---

## 📚 Week 6: 高度な状態管理

### Day 26: Shared State
**課題**: グローバル状態管理
- 要件:
  - [ ] ユーザー情報の共有
  - [ ] 通知バッジの更新
  - [ ] テーマ設定の共有
- 学習ポイント: @Shared, PersistenceKey, .appStorage, .fileStorage

### Day 27: File Upload
**課題**: ファイルアップロード機能
- 要件:
  - [ ] 画像選択
  - [ ] アップロード進捗表示
  - [ ] 複数ファイル同時アップロード
  - [ ] キャンセル機能
- 学習ポイント: Progress tracking

### Day 28: WebSocket
**課題**: リアルタイムチャット
- 要件:
  - [ ] WebSocket接続
  - [ ] メッセージ送受信
  - [ ] 接続状態の管理
  - [ ] 再接続処理
- 学習ポイント: AsyncStream

### Day 29: Background Task
**課題**: バックグラウンド処理
- 要件:
  - [ ] 定期的なデータ同期
  - [ ] バックグラウンドでの通知
  - [ ] タスクの優先度管理
- 学習ポイント: Background processing

### Day 30: Week 6 統合課題
**課題**: Notion風メモアプリ
- 要件:
  - [ ] リアルタイム同期
  - [ ] オフライン編集
  - [ ] 共同編集の状態表示
  - [ ] ファイル添付
  - [ ] 変更履歴の管理

**レビュー依頼**: 
```
「Week 6の統合課題を完成させました。複雑な状態管理についてLevel 3でレビューをお願いします。」
```

---

## 📚 Week 7: パフォーマンス最適化

### Day 31: Large List Optimization
**課題**: 1万件のリスト表示
- 要件:
  - [ ] 仮想スクロール
  - [ ] 遅延読み込み
  - [ ] メモリ使用量の最適化
- 学習ポイント: Performance optimization

### Day 32: Render Optimization
**課題**: 再レンダリング最適化
- 要件:
  - [ ] 不要な再描画の防止
  - [ ] @ObservableStateの適切な使用
  - [ ] Viewの分割
- 学習ポイント: Render optimization

### Day 33: Animation Performance
**課題**: 複雑なアニメーション
- 要件:
  - [ ] 60fps維持
  - [ ] ジェスチャー連動
  - [ ] 複数アニメーションの同期
- 学習ポイント: Animation with TCA

### Day 34: Memory Management
**課題**: メモリリーク対策
- 要件:
  - [ ] 循環参照の回避
  - [ ] 適切なキャンセレーション
  - [ ] リソースの解放
- 学習ポイント: Memory management

### Day 35: Week 7 統合課題
**課題**: YouTube風動画プレイヤー
- 要件:
  - [ ] 動画一覧（大量データ）
  - [ ] スムーズなスクロール
  - [ ] Picture in Picture
  - [ ] プリロード機能
  - [ ] メモリ効率的なキャッシュ

**レビュー依頼**: 
```
「Week 7の統合課題を完成させました。パフォーマンス最適化についてLevel 3でレビューをお願いします。」
```

---

## 📚 Week 8: 実務プロジェクト

### Day 36-40: 最終プロジェクト

**課題**: フルスタックTODOアプリ（Todoist風）

### 必須要件

**基本機能**:
- [ ] ユーザー認証（ログイン/ログアウト/サインアップ）
- [ ] プロジェクト管理（作成/編集/削除/アーカイブ）
- [ ] タスク管理（CRUD操作）
- [ ] サブタスク
- [ ] ラベル/タグ機能
- [ ] 優先度設定
- [ ] 期限設定と通知

**高度な機能**:
- [ ] フィルター/ソート/検索
- [ ] 今日/今週/カスタムビュー
- [ ] ドラッグ&ドロップでの並び替え
- [ ] 一括操作
- [ ] Undo/Redo
- [ ] ショートカットキー

**技術要件**:
- [ ] オフライン対応（完全な同期）
- [ ] リアルタイム同期
- [ ] プッシュ通知
- [ ] ダークモード
- [ ] iPad対応（レスポンシブ）
- [ ] Widget対応
- [ ] Siri Shortcuts

**品質要件**:
- [ ] 単体テスト（カバレッジ70%以上）
- [ ] 統合テスト（主要フロー）
- [ ] エラーハンドリング完備
- [ ] アクセシビリティ対応
- [ ] 国際化対応（日英）

### アーキテクチャ要件
- [ ] Feature分割が適切
- [ ] Dependencyの設計が拡張可能
- [ ] パフォーマンスが最適化されている
- [ ] コードが保守しやすい

### 提出物
1. ソースコード（GitHub）
2. READMEドキュメント
3. アーキテクチャ設計書
4. テストレポート

**最終レビュー依頼**: 
```
「8週間のカリキュラムを完了し、最終プロジェクトを作成しました。
実務レベルのコードとしてLevel 3で総合的なレビューをお願いします。
特に以下の点を重点的に見てください：
- アーキテクチャの設計
- コードの保守性
- パフォーマンス
- テストの品質
```

---

## 🎯 達成度チェックリスト

### 初級（Week 1-2 完了後）
- [ ] TCAの基本概念を理解している
- [ ] シンプルなアプリを作れる
- [ ] Effectを使った非同期処理ができる

### 中級（Week 3-4 完了後）
- [ ] Dependencyを適切に設計できる
- [ ] テストを書ける
- [ ] Navigationを実装できる
- [ ] Featureを適切に分割できる

### 上級（Week 5-6 完了後）
- [ ] 実践的なパターンを使える
- [ ] 複雑な状態管理ができる
- [ ] パフォーマンスを意識した実装ができる

### 実務レベル（Week 8 完了後）
- [ ] 大規模アプリの設計ができる
- [ ] チーム開発を意識したコードが書ける
- [ ] TCAのベストプラクティスを理解している
- [ ] 新規プロジェクトでTCAを採用できる

---
