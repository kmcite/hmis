/// Legacy composition root — use [package:hmis/utils/dependencies_scope.dart].
library;

import 'package:hmis/utils/dependencies_scope.dart';

export 'package:hmis/utils/dependencies_scope.dart';

@Deprecated('Use DependenciesScope from utils/dependencies_scope.dart')
typedef HmisProviders = DependenciesScope;
