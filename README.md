# PlayPlan

**仲間と遊びを繋ぐアプリ**

PlayPlanは、友達や仲間との旅行や遊びの計画を整理・管理するためのFlutterアプリケーションです。LINEのように情報が流れてしまう問題を解決し、プランごとに情報を整理して管理できます。

## 主な機能

### 1. グループ管理
- 仲間でグループを作成・管理
- メンバーの追加・削除
- グループごとにプランを整理

### 2. プラン管理
- 旅行や遊びの計画を作成
- 日程、場所、詳細を管理
- プランステータス管理（計画中、確定、実行中、完了）

### 3. チャット機能
- プランごとのチャット
- リアルタイムメッセージング
- 情報が流れず、プランに紐づいて整理

### 4. タスク管理
- プランごとのタスクリスト
- タスクの割り当てと期限設定
- 完了状態の管理

### 5. 費用管理
- 費用の記録と管理
- 割り勘計算
- 合計金額の表示

## 技術スタック

- **フレームワーク**: Flutter 3.9.2
- **状態管理**: Riverpod 2.5.1
- **バックエンド**: Firebase
  - Firebase Authentication（認証）
  - Cloud Firestore（データベース）
  - Firebase Storage（ファイル保存）
- **ルーティング**: Material Router

## セットアップ

### 1. 前提条件
- Flutter SDK (3.9.2以上)
- Firebase プロジェクト

### 2. インストール手順

```bash
# リポジトリをクローン
git clone <repository-url>
cd PlayPlan

# 依存パッケージをインストール
flutter pub get

# FlutterFire CLIをインストール（初回のみ）
dart pub global activate flutterfire_cli

# Firebaseプロジェクトを設定
flutterfire configure

# アプリを実行
flutter run
```

### 3. Firebase設定

1. [Firebase Console](https://console.firebase.google.com/)でプロジェクトを作成
2. Authentication、Firestore、Storageを有効化
3. `flutterfire configure`コマンドでFirebaseを設定

#### Firestoreセキュリティルール（例）

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーは自分のドキュメントのみ読み書き可能
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // グループメンバーのみアクセス可能
    match /groups/{groupId} {
      allow read: if request.auth != null &&
        request.auth.uid in resource.data.memberIds;
      allow write: if request.auth != null;
    }

    // プランは参加者のみアクセス可能
    match /plans/{planId} {
      allow read: if request.auth != null &&
        request.auth.uid in resource.data.participantIds;
      allow write: if request.auth != null;
    }

    // メッセージ、タスク、費用も同様
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }

    match /tasks/{taskId} {
      allow read, write: if request.auth != null;
    }

    match /expenses/{expenseId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## プロジェクト構造

```
lib/
├── main.dart                 # エントリーポイント
├── app.dart                  # アプリケーションルート
├── core/
│   ├── constants/           # 定数
│   ├── theme/               # テーマ設定
│   ├── routes/              # ルーティング
│   └── utils/               # ユーティリティ
├── models/                  # データモデル
│   ├── user.dart
│   ├── group.dart
│   ├── plan.dart
│   ├── message.dart
│   ├── task.dart
│   └── expense.dart
├── providers/               # Riverpodプロバイダー
│   ├── auth_provider.dart
│   └── firestore_provider.dart
├── services/                # サービスクラス
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/                 # 画面
│   ├── auth/               # 認証画面
│   ├── home/               # ホーム画面
│   ├── groups/             # グループ関連
│   ├── plans/              # プラン関連
│   └── chat/               # チャット
└── widgets/                 # 共通ウィジェット
```

## 使い方

1. **アカウント作成**: メールアドレスとパスワードでアカウントを作成
2. **グループ作成**: 仲間とのグループを作成
3. **プラン作成**: グループ内で旅行や遊びのプランを作成
4. **情報管理**: プランごとにタスク、費用、チャットを管理
5. **実行**: プランを実行し、完了までトラッキング

## 今後の拡張予定

- [ ] プッシュ通知
- [ ] 画像共有機能
- [ ] カレンダー連携
- [ ] 持ち物リスト
- [ ] 投票機能（日程調整など）
- [ ] 地図連携
- [ ] アプリ内決済

## ライセンス

このプロジェクトはプライベート使用のために作成されています。

## お問い合わせ

質問や提案がある場合は、Issueを作成してください。
