import 'dart:async';

import 'package:hmis/bussiness/business.dart';
import 'package:hmis/domain/services.dart';
import 'package:hmis/main.dart';
import 'package:hmis/utils/crud.dart';
import 'package:hmis/utils/redux.dart';
import 'package:redux/redux.dart';

/// VM
class Investigations {
  List<Investigation> all = [];
  Investigation? newInvestigation;
}

class InvestigationsReducer extends ReducerClass<Investigations> {
  @override
  Investigations call(Investigations state, action) {
    return switch (action) {
      RefreshInvestigations() => state..all = action.updates,
      NewInvestigationAction() =>
        state
          ..newInvestigation = newInvestigation(state.newInvestigation, action),
      _ => state,
    };
  }
}

class InvestigationsMW extends MiddlewareClass<Business> {
  StreamSubscription? _subscription;
  @override
  call(store, action, next) {
    next(action);
    _subscription ??= objects
        .box<Investigation>()
        .query()
        .watch(triggerImmediately: true)
        .listen((finder) => dispatch(RefreshInvestigations(finder.find())));
    switch (action) {
      case RemoveInvestigationAction():
        Remove(action.investigation.id);
      case AddInvestigationAction():
        if (store.state.investigations.newInvestigation != null)
          Put(store.state.investigations.newInvestigation!);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

sealed class InvestigationsAction {
  const InvestigationsAction();
}

class RefreshInvestigations extends InvestigationsAction {
  final List<Investigation> updates;
  const RefreshInvestigations(this.updates);
}

class AddInvestigationAction extends InvestigationsAction {
  const AddInvestigationAction();
}

class RemoveInvestigationAction extends InvestigationsAction {
  final Investigation investigation;
  const RemoveInvestigationAction(this.investigation);
}

/// NEW INVESTIGATION

class NewInvestigationAction extends InvestigationsAction {
  const NewInvestigationAction();
}

class CreateNewInvestigationStopped extends NewInvestigationAction {}

class CreateNewInvestigationStarted extends NewInvestigationAction {}

class NameChanged extends NewInvestigationAction {
  final String name;
  const NameChanged(this.name);
}

class PriceChanged extends NewInvestigationAction {
  final int price;
  const PriceChanged(this.price);
}

Investigation? newInvestigation(
  Investigation? state,
  NewInvestigationAction action,
) {
  return switch (action) {
    CreateNewInvestigationStarted() => Investigation(),
    NameChanged() => state?..name = action.name,
    PriceChanged() => state?..price = action.price,
    CreateNewInvestigationStopped() => null,
    _ => state,
  };
}
