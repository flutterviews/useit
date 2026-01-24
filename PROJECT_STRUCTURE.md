# 🏗 Project Structure Guide

## 📁 Recommended Folder Structure

```
lib/
├── core/                          # Core utilities (copy all files here)
│   ├── extensions.dart           # All extensions
│   ├── base_state.dart           # State classes
│   ├── data_state.dart           # API response states
│   ├── base_repository.dart      # Repository mixin
│   ├── base_response.dart        # Response models
│   ├── page_transitions.dart     # Route transitions
│   ├── prefs_service.dart        # SharedPreferences
│   └── utils.dart                # Helper functions
│
├── config/                        # App configuration
│   ├── router.dart               # GoRouter configuration
│   ├── theme.dart                # Theme configuration
│   └── constants.dart            # App constants
│
├── data/                          # Data layer
│   ├── models/                   # Data models
│   │   ├── user.dart
│   │   └── post.dart
│   │
│   ├── services/                 # API services (Retrofit)
│   │   └── api_service.dart
│   │
│   └── repositories/             # Repository implementations
│       ├── user_repository.dart
│       └── post_repository.dart
│
├── logic/                         # Business logic (Cubits/Blocs)
│   ├── user/
│   │   ├── user_cubit.dart
│   │   └── user_state.dart       # If not using BaseState
│   │
│   └── posts/
│       ├── posts_cubit.dart
│       └── posts_state.dart
│
├── presentation/                  # UI layer
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       └── home_card.dart
│   │   │
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   └── widgets/                  # Shared widgets
│       ├── loading_widget.dart
│       └── error_widget.dart
│
└── main.dart
```

## 🎯 Usage Examples by Feature

### 1. Simple API Call

```dart
// data/repositories/user_repository.dart
class UserRepository with BaseRepository {
  final ApiService api;

  UserRepository(this.api);

  Future<DataState<User>> getUser(String id) {
    return handleResponse(
      response: api.getUser(id),
      onNoConnection: 'Internet yo\'q',
    );
  }
}

// logic/user/user_cubit.dart
class UserCubit extends Cubit<BaseState<User>> {
  final UserRepository repository;

  UserCubit(this.repository) : super(BaseState.initial());

  Future<void> load(String id) async {
    emit(BaseState.loading());
    final result = await repository.getUser(id);
    
    result.when(
      success: (data) => emit(BaseState.success(data.data!)),
      failed: (error) => emit(BaseState.error(error.message!)),
    );
  }
}

// presentation/screens/user/user_screen.dart
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, BaseState<User>>(
      builder: (context, state) {
        if (state.status.isLoading) return LoadingWidget();
        if (state.status.isError) return ErrorWidget(state.error!);
        if (state.hasData) return UserProfile(state.data!);
        return SizedBox();
      },
    );
  }
}
```

### 2. Paginated List

```dart
// Repository
class PostRepository with BaseRepository {
  Future<DataState<List<Post>>> getPosts(int page) {
    return handleResponse(
      response: api.getPosts(page: page),
    );
  }
}

// Cubit
class PostsCubit extends Cubit<BasePagingState<Post>> {
  final PostRepository repository;

  PostsCubit(this.repository) : super(BasePagingState.initial());

  Future<void> loadMore() async {
    if (state.hasReachedMax) return;
    
    final status = state.items.isEmpty 
        ? PagingStatus.loading 
        : PagingStatus.paging;
    
    emit(state.copyWith(status: status));
    
    final result = await repository.getPosts(state.page);
    
    result.when(
      success: (data) {
        emit(state.copyWith(
          items: [...state.items, ...data.data!],
          status: PagingStatus.success,
          page: state.page + 1,
          hasReachedMax: data.data!.isEmpty,
        ));
      },
      failed: (error) => emit(state.copyWith(
        status: PagingStatus.error,
        error: error.message,
      )),
    );
  }
}

// UI
class PostsScreen extends StatefulWidget {
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PostsCubit>().loadMore();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostsCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, BasePagingState<Post>>(
      builder: (context, state) {
        if (state.status.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          controller: _scrollController,
          itemCount: state.items.length + (state.status.isPaging ? 1 : 0),
          separatorBuilder: (_, __) => 16.ph,
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return Center(child: CircularProgressIndicator());
            }
            return PostCard(state.items[index]);
          },
        );
      },
    );
  }
}
```

### 3. Form with Validation

```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            16.ph,
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            24.ph,
            ElevatedButton(
              onPressed: _onLogin,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _onLogin() {
    final email = _emailController.text;
    
    if (!email.isEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email')),
      );
      return;
    }

    context.read<AuthCubit>().login(
      email: email,
      password: _passwordController.text,
    );
  }
}
```

### 4. Navigation with GoRouter

```dart
// config/router.dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) {
        return HomeScreen().cupertinoTransition(state);
      },
    ),
    
    GoRoute(
      path: '/profile/:id',
      name: 'profile',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProfileScreen(id: id).fadeTransition(state);
      },
    ),
    
    GoRoute(
      path: '/modal',
      name: 'modal',
      pageBuilder: (context, state) {
        return ModalSheet().modalTransition(state);
      },
    ),
  ],
);

// Usage in widgets
ElevatedButton(
  onPressed: () => context.push('/profile/123'),
  child: Text('View Profile'),
)

IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => context.popSafe(),
)
```

## 🎨 Best Practices

### 1. Always use const
```dart
// ❌ Bad
Text('Hello')

// ✅ Good
const Text('Hello')
```

### 2. Use extensions for spacing
```dart
// ❌ Bad
SizedBox(height: 16)

// ✅ Good
16.ph
```

### 3. Handle errors properly
```dart
// ✅ Good
result.when(
  success: (data) {
    // Handle success
  },
  failed: (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message!)),
    );
  },
);
```

### 4. Clean up resources
```dart
@override
void dispose() {
  _controller.dispose();
  _debouncer.dispose();
  super.dispose();
}
```

### 5. Use meaningful names
```dart
// ❌ Bad
final d = await repo.get();

// ✅ Good
final userData = await userRepository.getUser(id);
```

## 🚀 Performance Optimization

1. **Use ListView.builder** for long lists
2. **Add const constructors** everywhere possible
3. **Cache expensive computations**
4. **Dispose controllers** properly
5. **Use RepaintBoundary** for complex widgets
6. **Implement pagination** for large datasets
7. **Use debouncing** for search/filter operations

## 📦 Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  
  # Navigation
  go_router: ^13.0.0
  
  # Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  
  # Storage
  shared_preferences: ^2.2.2
  
dev_dependencies:
  # Code Generation
  retrofit_generator: ^8.0.6
  build_runner: ^2.4.7
```