# TCA学習進捗記録

## 📚 Week 1: TCA基礎 - シンプルな状態管理

### ✅ Day 1: Counter App (2025/08/20)
**実装内容:**
- カウンターの増減機能
- リセット機能
- カウントの2倍表示（computed property）

**学んだこと:**
- TCAの基本構造（State, Action, Reducer）
- `@Reducer`, `@ObservableState`, `@Bindable`の使い方
- computed propertyによるState最小化

**改善点:**
- 初回実装で2倍表示を忘れていた → computed propertyの重要性を学習
- Action命名を`addButtonTapped` → `increaseButtonTapped`に改善

---

### ✅ Day 2: Counter with History (2025/08/20)
**実装内容:**
- 過去5回の操作履歴表示
- 履歴クリア機能

**学んだこと:**
- 配列の管理とサイズ制限
- 共通ロジックの実装方法（プライベート関数）
- 純粋なReducerの重要性

**改善点:**
- 初回実装でEffectを誤用 → 履歴追加は純粋なState変更として実装
- 履歴削除で`remove(at: 4)` → `removeLast()`に修正

---

### ✅ Day 3: Todo App - 基本 (2025/08/22)
**実装内容:**
- Todo追加（テキスト入力）
- スワイプ削除
- 完了/未完了の切り替え

**学んだこと:**
- IdentifiedArrayの基本使用
- BindableAction + BindingReducerパターン
- ForEachStoreは複雑なケースで使用（今回は不要）

**改善点:**
- 削除ボタン → スワイプ削除に変更
- `firstIndex` → `state.todos[id: todo.id]`で効率化
- Todo追加後のテキストクリアを追加

---

### ✅ Day 4: Todo with Filter (2025/08/22)
**実装内容:**
- All/Active/Completedフィルター
- 各フィルターのカウント表示
- フィルター状態の保持

**学んだこと:**
- computed propertyでのフィルタリング
- 元データを変更せずに表示制御
- 複数のcomputed propertyの効果的な活用

**改善点:**
- フィルター時の削除処理バグを修正
- 各フィルターのカウント表示を追加
- Force unwrapを安全な実装に変更

---

### ✅ Day 5: Week 1 統合課題 - メモアプリ (2025/08/24)
**実装内容:**
- メモのCRUD操作
- 文字数カウント表示
- 作成日時/更新日時での並び替え
- モーダルでの新規作成/編集

**学んだこと:**
- 複数機能の統合方法
- IdentifiedArrayのソート（`IdentifiedArray(uniqueElements:)`）
- 日付フォーマッティング
- structの更新は必ず代入し直す

**改善点:**
- typo修正（Feture → Feature）
- 作成日時の表示を追加
- 空文字チェックでボタンを無効化
- 未使用Actionを削除

---

## 🎯 Week 1で習得したスキル

### TCAの基本概念
- ✅ State設計: 最小限のプロパティ、computed property活用
- ✅ Action設計: 明確な命名、BindableAction
- ✅ Reducer: 純粋関数、副作用なし
- ✅ 配列管理: IdentifiedArray、効率的な操作

### ベストプラクティス
- ✅ Force unwrapを避ける
- ✅ 共通ロジックの適切な扱い方
- ✅ computed propertyで派生データを管理
- ✅ BindingReducerでのフォーム処理

### コードレビューで学んだこと
- 🔴 必ず修正すべき点: 要件の見落とし、バグ、unsafe code
- 🟡 改善を推奨する点: より良い実装方法、命名規則
- 🟢 良い実装: 積極的に評価してもらえた点

---

## 📈 成長の記録

**Day 1-2**: TCAの基本構造を理解
- 最初はEffectを誤用したが、純粋なReducerの重要性を学習

**Day 3-4**: 実践的な機能実装
- IdentifiedArrayの効率的な使い方を習得
- computed propertyの威力を実感

**Day 5**: 知識の統合
- 学んだ要素をすべて組み合わせて実装
- 自信を持ってTCAの基本を扱えるように

---

## 🚀 次のステップ: Week 2

**予定している学習内容:**
- Effect と 非同期処理
- Timer, API通信
- Debounce, Cancel
- Error handling
- Dependencies

**目標:**
- 非同期処理を含むより実践的なアプリの実装
- テスト可能な設計の理解