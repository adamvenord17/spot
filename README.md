# Spot

```sql
create table public.users (
  id uuid references auth.users not null primary key,
  name varchar(18) UNIQUE,
  description varchar(320),
  image_url text
);
comment on table pulbic.users is 'Holds all of users profile information';

create table public.posts (
  id uuid not null primary key,
  creator_uid uuid references public.users not null,
  created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
  video_url text,
  thumbnail_url text,
  gif_url text,
  description varchar(320)
);
comment on table public.rooms is 'Holds all the video posts.';

create table public.comments (
  id uuid not null primary key,
  post_id uuid references public.posts not null,
  creator_uid uuid references public.users not null,
  created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
  text varchar(320)
);
comment on table public.comments is 'Holds all of the comments created by the users.';

create table public.likes (
    id uuid not null primary key,
    post_id uuid references public.posts not null,
    creator_uid uuid references public.users not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null
);
comment on table public.likes is 'Holds all of the like data created by thee users.';

create table public.follow (
    following_user_id not null primary key,
    followed_user_id not null primary key,
    followed_at timestamp with time zone default timezone('utc' :: text, now()) not null
);
comment on table public.follow is 'Creates follow follower relationships';
```





![coverage][coverage_badge]

[![License: MIT][license_badge]][license_link]





---

## Getting Started 🚀

This project contains 3 flavors:

- development
- staging
- production

To run the desired flavor either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart

# Production
$ flutter run --flavor production --target lib/main_production.dart
```

_*Spot works on iOS, Android, and Web._

---

## Running Tests 🧪

To run all unit and widget tests use the following command:

```sh
$ flutter test --coverage --test-randomize-ordering-seed random
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

## Working with Translations 🌐

This project relies on [flutter_localizations][flutter_localizations_link] and follows the [official internationalization guide for Flutter][internationalization_link].

### Adding Strings

1. To add a new localizable string, open the `app_en.arb` file at `lib/l10n/arb/app_en.arb`.

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

2. Then add a new key/value and description

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    },
    "helloWorld": "Hello World",
    "@helloWorld": {
        "description": "Hello World Text"
    }
}
```

3. Use the new string

```dart
import 'package:spot/l10n/l10n.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  return Text(l10n.helloWorld);
}
```

### Adding Supported Locales

Update the `CFBundleLocalizations` array in the `Info.plist` at `ios/Runner/Info.plist` to include the new locale.

```xml
    ...

    <key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>es</string>
	</array>

    ...
```

### Adding Translations

1. For each supported locale, add a new ARB file in `lib/l10n/arb`.

```
├── l10n
│   ├── arb
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

2. Add the translated strings to each `.arb` file:

`app_en.arb`

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

`app_es.arb`

```arb
{
    "@@locale": "es",
    "counterAppBarTitle": "Contador",
    "@counterAppBarTitle": {
        "description": "Texto mostrado en la AppBar de la página del contador"
    }
}
```











