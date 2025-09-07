# Week 3: Dependencies とテスト - 学習記録

## 概要
Week 3では、TCAにおけるDependency管理とテスト実装について学習しました。実務で必要不可欠なテスタビリティの高いコード設計と、包括的なテスト戦略を身につけることができました。

## 学習内容

### Day 11: Dependency Injection
**実装内容**: Weather APIのDependency化
- **学んだこと**:
  - `@Dependency`マクロの使い方
  - `DependencyKey`プロトコルの実装
  - Live/Test/Preview値の分離
- **ポイント**: 
  - テスト時にモックを注入できる設計
  - プレビューでの動作確認の容易化

### Day 12: UserDefaults Dependency
**実装内容**: 設定画面とUserDefaults永続化
- **学んだこと**:
  - UserDefaultsの抽象化
  - 永続化処理のDependency化
  - `@Sendable`の適切な使用
- **課題と解決**:
  - Pickerのバインディング → `BindableAction`で解決
  - 初期読み込みタイミング → `onAppear`を使用

### Day 13: Test Writing (基礎)
**実装内容**: Day 1-3の基本的なテスト
- **学んだこと**:
  - Swift Testingフレームワーク（`@Test`, `#expect`）
  - `TestStore`の基本的な使い方
  - 同期的なActionのテスト方法
- **重要な気づき**:
  - XCTestからSwift Testingへの移行
  - `@MainActor`の必要性
  - UUID生成のDependency化

### Day 14: Test Writing (非同期)
**実装内容**: Day 6-8の非同期処理テスト
- **学んだこと**:
  - `TestClock`を使った時間制御
  - Effectのキャンセレーションテスト
  - 非同期処理の順序保証
- **デバッグ経験**:
  - Debounceテストでの予期しないAction
  - `exhaustivity`の使い分け
  - 実装設計の見直し

### Day 15: Week 3 統合課題（ログイン機能）
**実装内容**: 完全なログイン機能とテスト
- **統合した要素**:
  - フォームバリデーション
  - 非同期API呼び出し
  - トークン永続化
  - 自動ログアウトタイマー
  - 包括的なテストカバレッジ
- **設計の工夫**:
  - `clock.sleep`を使ったシンプルなタイマー実装
  - Dependency注入による高いテスタビリティ
  - エラーハンドリングの網羅

## 技術的な学び

### Dependency設計のベストプラクティス
```swift
// 1. プロトコルベースの抽象化
struct AuthClient {
    var login: @Sendable (String, String) async throws -> AuthToken
}

// 2. DependencyKeyの実装
extension AuthClient: DependencyKey {
    static let liveValue = Self(...)
    static let testValue = Self(...)
}

// 3. テストでの使用
withDependencies: {
    $0.authClient.login = { _, _ in mockToken }
}
```

### テスト戦略
1. **初期状態テスト**: 全プロパティの確認
2. **Action単位テスト**: 各Actionの動作検証
3. **統合テスト**: 複数Actionの連携確認
4. **エッジケーステスト**: エラーやキャンセレーション

### Swift Testingの利点
- より直感的なAPI（`#expect`）
- `@MainActor`の自動適用
- パラメータ化テストのサポート
- より詳細なエラーメッセージ

## 実装上の課題と解決

### 1. Debounce実装の設計問題
**問題**: 複数の検索が実行される
**原因**: Action経由での間接的な実装
**解決**: 直接Effectで検索を実行する設計への変更

### 2. テストでのEffect管理
**問題**: 長時間実行されるEffectのテスト
**解決策**:
- `exhaustivity = .off`の活用
- `TestClock`での時間制御
- 適切なキャンセレーション

### 3. バリデーションロジック
**改善点**: 空文字列時のエラーリセット処理
**学び**: すべての状態遷移を考慮する重要性

## 成長の実感

### できるようになったこと
- ✅ Dependencyを使った疎結合な設計
- ✅ テスタブルなコードの実装
- ✅ 非同期処理の適切なテスト
- ✅ 複雑な機能の統合的な実装

### 次のステップへの準備
Week 3で学んだDependency設計とテスト実装のスキルは、Week 4のNavigation実装でも重要な基礎となります。特に、画面間の連携やデータの受け渡しをテスタブルに実装する際に活用できます。

## まとめ
Week 3を通じて、TCAにおける実務レベルの設計パターンを習得できました。特にDependency Injectionとテスト実装は、大規模なアプリケーション開発において不可欠なスキルです。この週で学んだ内容は、今後のTCA開発の強固な基盤となるでしょう。