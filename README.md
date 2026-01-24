# Flutter Core Utilities

Professional, performance-optimized utilities for Flutter development.

## 📦 Installation

Copy the files directly into your project:

```
lib/
  core/
    extensions.dart
    base_state.dart
    data_state.dart
    base_repository.dart
    base_response.dart
    page_transitions.dart
    prefs_service.dart
    utils.dart
```

## 🚀 Features

### ✨ Extensions

#### Color Extension
```dart
final color = "#FF5733".toColor;  // Hex to Color
final hex = Colors.red.toHex();    // Color to Hex
```

#### Padding Extension
```dart
Column(
  children: [
    Text('Hello'),
    16.ph,  // Vertical space
    Text('World'),
  ],
)

Row(
  children: [
    Icon(Icons.star),
    8.pw,  // Horizontal space
    Text('Rating'),
  ],
)
```

#### Screen Size Extension
```dart
final width = context.width;
final height = context.height;
final padding = context.padding;
```

#### Navigation Extension
```dart
context.popSafe();  // Safe pop with error handling
context.canPop;     // Check if can pop
```

#### Dio Error Extension
```dart
try {
  await dio.get('/api');
} on DioException catch (e) {
  if (e.isNoConnection) {
    showSnackbar('No internet');
  } else if (e.isUnauthorized) {
    navigateToLogin();
  }
}
```

#### String Extension
```dart
'camelCase'.toSnakeCase;        // 'camel_case'
'hello'.capitalize;              // 'Hello'
'test@email.com'.isEmail;        // true
```

### 🎯 State Management

#### BaseState
```dart
class UserCubit extends Cubit<BaseState<User>> {
  UserCubit() : super(BaseState.initial());

  Future<void> loadUser() async {
    emit(BaseState.loading());
    
    final result = await repository.getUser();
    
    result.when(
      success: (data) => emit(BaseState.success(data.data!)),
      failed: (error) => emit(BaseState.error(error.message!)),
    );
  }
}

// UI
BlocBuilder<UserCubit, BaseState<User>>(
  builder: (context, state) {
    if (state.status.isLoading) return CircularProgressIndicator();
    if (state.status.isError) return Text(state.error!);
    if (state.hasData) return Text(state.data!.name);
    return SizedBox();
  },
)
```

#### BasePagingState
```dart
class PostsCubit extends Cubit<BasePagingState<Post>> {
  PostsCubit() : super(BasePagingState.initial());

  Future<void> loadPosts() async {
    emit(state.copyWith(status: PagingStatus.loading));
    
    final result = await repository.getPosts(page: state.page);
    
    result.when(
      success: (data) {
        final newItems = [...state.items, ...data.data!];
        emit(state.copyWith(
          items: newItems,
          status: PagingStatus.success,
          hasReachedMax: data.data!.isEmpty,
          page: state.page + 1,
        ));
      },
      failed: (error) => emit(state.copyWith(
        status: PagingStatus.error,
        error: error.message,
      )),
    );
  }
}
```

### 🌐 Repository Pattern

```dart
class UserRepository with BaseRepository {
  final ApiService api;

  UserRepository(this.api);

  Future<DataState<User>> getUser(String id) {
    return handleResponse(
      response: api.getUser(id),
      onNoConnection: 'Internet yo\'q',
      onError: 'Xatolik yuz berdi',
    );
  }

  Future<DataState<List<User>>> getUsers() {
    return handleResponse(
      response: api.getUsers(),
    );
  }
}
```

### 🎨 Page Transitions

```dart
GoRoute(
  path: '/profile',
  pageBuilder: (context, state) {
    return ProfileScreen().cupertinoTransition(state);
  },
),

GoRoute(
  path: '/modal',
  pageBuilder: (context, state) {
    return ModalScreen().modalTransition(state);
  },
),
```

### 💾 Preferences

```dart
// Save
await Prefs.setString('token', 'abc123');
await Prefs.setBool('isLoggedIn', true);

// Read
final token = await Prefs.getString('token');
final isLoggedIn = await Prefs.getBool('isLoggedIn') ?? false;

// Delete
await Prefs.remove('token');
await Prefs.clear();
```

### 🛠 Utils

```dart
// Hide keyboard
hideKeyboard();

// Measure text
final size = measureText('Hello', style: TextStyle(fontSize: 16));

// Debounce
final debouncer = Debouncer(milliseconds: 500);
TextField(
  onChanged: (value) {
    debouncer.run(() {
      search(value);
    });
  },
);
```

## 📋 Complete Example

```dart
// 1. API Service (Retrofit)
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  @GET('/users/{id}')
  Future<HttpResponse<BaseResponse<User>>> getUser(@Path('id') String id);
}

// 2. Repository
class UserRepository with BaseRepository {
  final ApiService api;

  UserRepository(this.api);

  Future<DataState<User>> getUser(String id) {
    return handleResponse(
      response: api.getUser(id),
      onNoConnection: 'Check your internet',
      onError: 'Failed to load user',
    );
  }
}

// 3. Cubit
class UserCubit extends Cubit<BaseState<User>> {
  final UserRepository repository;

  UserCubit(this.repository) : super(BaseState.initial());

  Future<void> loadUser(String id) async {
    emit(BaseState.loading());
    
    final result = await repository.getUser(id);
    
    result.when(
      success: (data) => emit(BaseState.success(data.data!)),
      failed: (error) => emit(BaseState.error(error.message!)),
    );
  }
}

// 4. UI
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.popSafe(),
        ),
      ),
      body: BlocBuilder<UserCubit, BaseState<User>>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state.status.isError) {
            return Center(child: Text(state.error!));
          }
          
          if (state.hasData) {
            final user = state.data!;
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(user.name),
                  16.ph,  // Vertical spacing
                  Text(user.email),
                ],
              ),
            );
          }
          
          return SizedBox();
        },
      ),
    );
  }
}
```

## ⚡ Performance Tips

1. **Use const constructors** where possible
2. **Lazy initialization** - Services only initialize when needed
3. **Minimal rebuilds** - State management optimized for performance
4. **No global state** - All utilities are stateless or use local state
5. **Efficient extensions** - All extensions are inline and compile-time safe

## 📝 License

Use freely in your projects.