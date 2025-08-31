# Week 2: 非同期処理とEffect - 学習まとめ

## 📚 Week 2の概要

Week 2では、TCAにおける非同期処理の扱い方を学習しました。Effect、Timer、API通信、Debounce、並列処理など、実践的な非同期パターンを習得しました。

---

## Day 6: Timer App

### 学んだこと
- **Effect**: 副作用を扱う仕組み
- **Timer**: `continuousClock`を使った定期処理
- **Cancellation**: `.cancellable(id:)`でキャンセル可能に

### 重要なコード
```swift
// タイマーの実装
return .run { send in
    for await _ in clock.timer(interval: .seconds(1)) {
        await send(.tick)
    }
}
.cancellable(id: CancelID.timer)

// 停止
return .cancel(id: CancelID.timer)
```

### ポイント
- `@Dependency(\.continuousClock)`でテスタブルに
- enumでCancelIDを管理
- 同じIDで自動的に前のEffectがキャンセル

---

## Day 7: API Client (Mock)

### 学んだこと
- **TaskResult**: 非同期処理の成功/失敗を扱う
- **Error handling**: エラー状態の管理
- **Dependency Injection**: モックAPIの実装

### 重要なコード
```swift
// API呼び出し
return .run { send in
    await send(.weatherResponse(
        TaskResult {
            try await weatherClient.fetchWeather()
        }
    ))
}

// レスポンス処理
case .weatherResponse(.success(let weather)):
    state.weather = weather
case .weatherResponse(.failure(let error)):
    state.error = error.localizedDescription
```

### ポイント
- ClientをDependencyとして実装
- モックで遅延とランダムエラーを再現
- リトライ機能の実装

---

## Day 8: Search with Debounce

### 学んだこと
- **Debounce**: 連続入力を最後の1回に集約
- **自動キャンセル**: 同じIDで前の処理を自動キャンセル
- **BindingAction**: TextFieldとの連携

### 重要なコード
```swift
case .binding(\.searchText):
    guard !state.searchText.isEmpty else {
        return .cancel(id: CancelID.search)
    }
    return .run { send in
        try await clock.sleep(for: .milliseconds(500))
        await send(.search)
    }
    .cancellable(id: CancelID.search)
```

### Debounceの仕組み
```
入力: A--B----C--D-E--------→
      ↓  ↓    ↓  ↓ ↓
      ×  ×    ×  × ↓ (前のをキャンセル)
                    ↓
                    500ms後
                    ↓
実行: ----------------E-----→
```

---

## Day 9: Parallel Effects

### 学んだこと
- **Effect.merge**: 複数のEffectを並列実行
- **個別の状態管理**: 各APIごとのローディング状態
- **統合的なエラー処理**: 1つでも失敗したらエラー

### 重要なコード
```swift
// 並列実行
return .merge(
    .run { send in await send(.fetchUser) },
    .run { send in await send(.fetchPosts) },
    .run { send in await send(.fetchSettings) }
)
```

### ポイント
- 各APIクライアントを個別に管理
- 全体の完了状態をcomputed propertyで判定
- エラー時のUI制御

---

## Day 10: GitHub検索アプリ（統合課題）

### 実装した機能
1. **キーワード検索（Debounce付き）**
2. **検索結果表示とエラーハンドリング**
3. **お気に入り登録（ローカル保存）**
4. **検索履歴の管理**
5. **ページネーション**

### 統合された技術
- Day 6: キャンセル可能なEffect
- Day 7: API通信とエラーハンドリング
- Day 8: Debounceパターン
- Day 9: 複数の状態管理

### 学んだ実装パターン
```swift
// Debounce + 自動検索
case .binding(\.searchText):
    // 空文字チェックとキャンセル
    // 500ms待機
    // 検索実行

// 値型の更新
if var repo = state.repositories[id: repository.id] {
    repo.isFavorite = true
    state.repositories[id: repository.id] = repo  // 重要！
}

// ページネーション
case .loadNextPage:
    guard state.hasMorePages && !state.isLoading else { return .none }
    // 次ページ読み込み
```

---

## 🎯 Week 2で習得したスキル

### Effect パターン
- ✅ `.run { send in }` による非同期処理
- ✅ `.cancellable(id:)` でのキャンセル管理
- ✅ `.merge()` での並列実行
- ✅ `.cancel(id:)` での明示的キャンセル

### 非同期処理のベストプラクティス
- ✅ TaskResult でのエラーハンドリング
- ✅ Dependency Injection でのテスタビリティ
- ✅ 適切なローディング状態の管理
- ✅ Debounce による最適化

### 実装のコツ
1. **state内の値を`.run`で使う場合**
   ```swift
   let value = state.value  // 事前に取得
   return .run { send in
       // valueを使用
   }
   ```

2. **キャンセルIDの管理**
   ```swift
   private enum CancelID {
       case timer
       case search
       case api
   }
   ```

3. **値型の更新パターン**
   ```swift
   // 取得 → 変更 → 代入
   if var item = state.items[id: id] {
       item.property = newValue
       state.items[id: id] = item
   }
   ```

---

## 🚀 Week 3への準備

Week 3では以下を学習予定：
- Dependencies の詳細
- テストの書き方
- UserDefaults での永続化
- より高度なパターン

Week 2で学んだ非同期処理の基礎は、実践的なアプリ開発で必須のスキルです。
これらのパターンを組み合わせることで、複雑な要件にも対応できるようになりました！