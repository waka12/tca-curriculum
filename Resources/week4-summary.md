# Week 4: Navigation と Composition - 学習記録

## 概要
Week 4では、TCAにおける複雑な画面構成とFeatureの組み合わせについて学習しました。NavigationStackを使った階層的な画面遷移から、TabViewとの組み合わせ、モーダル表示の管理、そして Feature間の通信パターンまで、実際のアプリ開発で必要となる実践的なパターンを習得しました。

## 学習内容

### Day 16: Navigation Stack
**実装内容**: 3階層のナビゲーション（List → Detail → Edit）
- **学んだこと**:
  - `@Presents + Destination`パターンによるNavigation管理
  - `NavigationStack`の基本的な使い方
  - Feature間のデータ受け渡し（Delegate Action）
  - `.navigationDestination`モディファイアの活用
- **重要な気づき**:
  - Deep Linkは学習の本質ではないため、シンプルさを重視
  - 橋渡しパターンによる親子Feature間の通信
  - データフローの明確化の重要性

### Day 17: Tab + Navigation
**実装内容**: 2タブアプリ（Items/Favorites）とタブ間データ共有
- **学んだこと**:
  - `@Shared`によるタブ間のリアルタイム状態共有
  - `Scope`を使った子Featureへの状態・アクション分離
  - `withLock`によるスレッドセーフな@Shared値更新
  - Single Source of Truthの実現（favoriteIDsのみで管理）
- **設計の工夫**:
  - computed propertyによるリアクティブな表示更新
  - 最小限のコードで要件を実現
  - データの重複管理を避けたクリーンな設計

### Day 18: Modal Presentation
**実装内容**: 4種類のモーダル表示（sheet、fullScreenCover、alert、confirmationDialog）
- **学んだこと**:
  - `Destination`パターンによる複数モーダルの統一管理
  - `AlertState`と`ConfirmationDialogState`の実装
  - 各モーダルタイプの適切な使い分け
  - `@Presents`を使ったモーダル状態管理
- **実装パターン**:
  - View側での`scope`使用による型安全な状態管理
  - AlertとDialogの拡張による再利用可能な実装
  - モーダル内でのインタラクション設計

### Day 19: Parent-Child Communication
**実装内容**: 親子Feature間の通信とデータフロー
- **学んだこと**:
  - Delegate Actionパターンによる子から親への通知
  - `@Shared`と従来の橋渡しパターンの使い分け
  - 兄弟Feature間の通信（親を介した連携）
  - NavigationStackとの組み合わせ
- **設計の創造性**:
  - @Sharedを活用した自動同期の実現
  - 純粋なDelegate patternと@Sharedの組み合わせ
  - 要件を満たしつつ実用性を向上させる工夫

### Day 20: Week 4 統合課題（Slack風チャットアプリ）
**実装内容**: 3タブ構成の本格的なチャットアプリUI
- **統合した要素**:
  - 3つのTab（Channels、DM、Settings）
  - 3階層Navigation（Channel → MessageList → MessageDetail）
  - モーダルでの新規メッセージ作成
  - グローバルなメンション通知システム
- **技術的なハイライト**:
  - `@Shared`を使ったグローバル通知システムの実装
  - App側での`onChange`監視による全画面Alert表示
  - Week 4全体の学習内容の完全統合
  - 実用的なUI/UXの実現

## 技術的な学び

### @Sharedの深い理解
```swift
// グローバル状態の共有
@Shared(.inMemory("key")) var globalState: State

// スレッドセーフな更新
state.$globalState.withLock { $0 = newValue }

// onChange監視によるリアクティブ処理
.onChange(of: store.globalState) { _, newValue in
    store.send(.globalStateChanged(newValue))
}
```

### Navigationパターンの使い分け
- **@Presents + Destination**: シンプルな階層構造（Day 16, 20）
- **StackState**: 複雑なナビゲーション履歴管理（今回は使用せず）
- **適材適所の判断**: 要件に応じた最適なパターン選択

### Feature設計の原則
1. **独立性**: 各Featureは独立して動作可能
2. **責務の分離**: 明確な役割分担
3. **再利用性**: 他の場面でも使える設計
4. **テスタビリティ**: TestStoreで検証可能

### モーダル管理のベストプラクティス
```swift
@Reducer
enum Destination {
    case sheet(SheetFeature)
    case fullScreen(FullScreenFeature)
    case alert(AlertState<Action.Alert>)
    case confirmDialog(ConfirmationDialogState<Action.Dialog>)
}
```

## 実装上の課題と解決

### 1. @Sharedの哲学的なトレードオフ
**課題**: TCAの単方向データフローと@Sharedの使用バランス
**解決アプローチ**:
- グローバル設定や認証情報: @Sharedが適切
- 複雑なビジネスロジック: 従来の橋渡しパターン
- チームでの使用方針統一の重要性

### 2. グローバル通知システムの設計
**課題**: どの画面からでもメンション通知を受け取る仕組み
**解決策**:
- App側での@Shared値監視
- onChange + AlertStateによる統一的なAlert表示
- 各タブからの通知トリガー実装

### 3. モーダル管理の統一性
**課題**: 複数種類のモーダルの一元管理
**解決パターン**:
- Destinationパターンによる型安全な管理
- View側でのscope使用による状態分離
- AlertState/ConfirmationDialogStateの拡張による再利用性

## 成長の実感

### できるようになったこと
- ✅ 複雑な画面構成の設計と実装
- ✅ NavigationStackを使った階層的な画面遷移
- ✅ タブ間でのリアルタイムデータ共有
- ✅ 複数種類のモーダル表示の統一管理
- ✅ Feature間の効率的な通信設計
- ✅ @Sharedと従来パターンの適切な使い分け

### 設計思考の向上
- **要件の本質理解**: Deep Linkよりも学習目標の重視
- **実用性と学習のバランス**: @Sharedによる効率化と学習効果の両立
- **グローバル設計**: アプリレベルでの状態管理の必要性判断
- **パターンの選択**: 要件に最適な実装方法の選択能力

### TCAマスタリーへの道筋
Week 4を通じて、TCAにおける実践的なアプリケーション設計の基礎を完全に習得しました。特に@Sharedの効果的な活用と、従来のDelegate patternとの使い分けは、実務レベルの判断力を身につけた証拠です。

## 次のステップへの準備

Week 4で学んだNavigation、Tab管理、Modal表示、Feature間通信のスキルは、Week 5以降のより実践的なパターン学習の強固な基盤となります。特に、@Sharedを使ったグローバル状態管理の理解は、大規模アプリケーション開発において重要な武器となるでしょう。

## まとめ

Week 4では、TCAにおける複雑なUI構造の実装方法を体系的に学習しました。単なる技術的な実装にとどまらず、設計思考や要件の本質理解、そして実用性を重視した判断力も大幅に向上しました。Slack風チャットアプリの完成により、Week 1-4で学んだすべての知識が統合され、実務で通用するレベルのTCAスキルを身につけることができました。

これで、TCAの基礎から実践的な応用まで、堅実な土台が完成しています。Week 5以降の高度なパターン学習に向けて、十分な準備が整いました。