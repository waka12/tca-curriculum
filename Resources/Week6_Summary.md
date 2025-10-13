# Week 6: 高度な状態管理 - 学習記録

## 📚 Week 6 概要
**期間**: Day 26-30  
**テーマ**: エンタープライズレベルの状態管理とリアルタイム機能の実装

## 🎯 学習成果

### Day 26: @Shared による高度な状態管理
**実装内容**: グローバル状態管理システム

**技術ポイント**:
- **@Shared の3つの永続化方法**:
  - `.appStorage`: UserDefaultsを使った軽量データの永続化
  - `.inMemory`: アプリ実行中のみ保持される一時的な共有状態
  - `.fileStorage`: JSONファイルによる構造化データの永続化
- **実装例**:
  ```swift
  @Shared(.appStorage("userName")) var userName: String = ""
  @Shared(.inMemory("unreadCount")) var unreadCount: Int = 0
  @Shared(.fileStorage(.documentsDirectory.appending(component: "theme.json")))
  var theme = Theme.light
  ```

**学習ポイント**: 
- 永続化が必要なデータと一時的なデータの適切な使い分け
- Codable準拠による複雑なデータ構造の永続化
- Feature間でのグローバル状態の共有パターン

### Day 27: AsyncStreamによるファイルアップロード
**実装内容**: 進捗表示付きファイルアップロード機能

**技術ポイント**:
- **AsyncStream**: Swift標準の非同期イベントストリーム
- **進捗管理の実装**:
  ```swift
  for await progress in day27UploadClient.upload(uploadItem) {
      await send(.updateProgress(uploadItem.id, progress))
  }
  ```
- **URLSessionの進捗追跡**: `fractionCompleted`を使った実装

**学習ポイント**:
- AsyncStreamはTCA独自ではなくSwift標準機能
- 複数ファイルの同時アップロード管理
- キャンセレーション処理の重要性

### Day 28: WebSocketによるリアルタイム通信
**実装内容**: echo.websocket.orgを使った実践的なチャット機能

**技術ポイント**:
- **URLSessionWebSocketTask**: Apple標準のWebSocket実装
- **自動再接続ロジック**: 最大3回までのリトライ機能
- **Actor パターン**: スレッドセーフな接続管理
  ```swift
  actor WebSocketClient {
      private var task: URLSessionWebSocketTask?
      private var continuation: AsyncStream<WebSocketEvent>.Continuation?
  }
  ```

**実装の特徴**:
- エコーサーバーでの実装により、サーバー不要でWebSocket動作確認
- 接続状態の適切な管理（connected/disconnected/error）
- リアルタイムメッセージングの基本パターン習得

### Day 29: Task Priorityによるバックグラウンド処理
**実装内容**: 優先度付きタスク実行システム

**技術ポイント**:
- **Task Priority の3段階**: high, medium, low
- **型の競合解決**: `_Concurrency.TaskPriority`の明示的使用
- **優先度による実行順序制御**:
  ```swift
  try await Task(priority: .high) {
      // 高優先度で実行される処理
  }.value
  ```

**重要な学習**:
- `.value`による非同期タスクの完了待機
- グローバルなタスクスケジューラーによる優先度管理
- 実務での適切な優先度設計の難しさ

### Day 30: Week 6 統合課題 - Notion風メモアプリ
**実装内容**: 全技術を統合した実践的アプリケーション

**統合された技術**:
1. **@Shared (.fileStorage)**: オフラインメモの永続化
2. **WebSocket**: リアルタイム同期と編集状態の共有
3. **File Upload**: 画像添付機能（進捗表示付き）
4. **Task Priority**: オフライン→オンライン時の高優先度同期

**実装のハイライト**:
```swift
case .binding(\.isOnlineToggle):
    if state.isOnlineToggle && !state.offlineMemos.isEmpty {
        return .run { [offlineMemos = state.offlineMemos] send in
            try await Task(priority: .high) {
                for memo in offlineMemos {
                    try await day30LikeNotionClient.send(memo)
                }
            }.value
            await send(.clearOfflineMemos)
        }
    }
```

## 💡 重要な学習ポイント

### 1. WebSocketでのデータ送信
- WebSocketは基本的に文字列またはバイナリデータを送信
- 構造化データ（Codable）は JSON文字列に変換して送信
- 実装例: `Memo → JSONEncoder → Data → String → WebSocket送信`

### 2. Task Priority の理解
- システム全体で管理される優先度（ファイル/Feature横断）
- 完璧な優先度管理は複雑だが、重要な処理には高優先度を設定
- `.value`によるタスク完了待機パターン

### 3. オフライン対応の実装パターン
- @Sharedによるローカル永続化
- オンライン復帰時の自動同期
- 同期状態の可視化（UI表示）

### 4. 実務での適用性
- WebSocket同期: 実際のコラボレーションツールで使用
- オフライン編集: モバイルアプリの必須要件
- ファイルアップロード: 一般的な機能要件
- 優先度管理: パフォーマンス最適化に重要

## 🚀 次のステップ
Week 7では、これらの高度な状態管理を基盤として、パフォーマンス最適化に焦点を当てます：
- 大量データの効率的な処理
- レンダリング最適化
- メモリ管理
- アニメーションパフォーマンス