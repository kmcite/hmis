import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_surface.dart';
import 'liquid_tokens.dart';
import 'liquid_variant.dart';

/// Inset liquid field — use [initialValue] + [onChanged] or an external [controller].
class LiquidTextField extends StatefulWidget {
  const LiquidTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  State<LiquidTextField> createState() => _LiquidTextFieldState();
}

class _LiquidTextFieldState extends State<LiquidTextField> {
  late FocusNode _focusNode;
  TextEditingController? _controller;
  var _ownsController = false;
  var _ownsFocus = false;
  var _focused = false;

  bool get _multiline =>
      widget.maxLines > 1 || (widget.minLines ?? 1) > 1;

  @override
  void initState() {
    super.initState();
    _bindController();
    _bindFocus();
  }

  void _bindController() {
    if (widget.controller != null) {
      _controller = widget.controller;
      return;
    }
    _ownsController = true;
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  void _bindFocus() {
    _ownsFocus = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) setState(() => _focused = focused);
  }

  @override
  void didUpdateWidget(LiquidTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller?.dispose();
      }
      _bindController();
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocus);
      if (_ownsFocus) _focusNode.dispose();
      _bindFocus();
    }

    if (_ownsController &&
        widget.initialValue != oldWidget.initialValue &&
        !_focusNode.hasFocus) {
      final next = widget.initialValue ?? '';
      if (_controller!.text != next) {
        _controller!.value = _controller!.value.copyWith(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    if (_ownsFocus) _focusNode.dispose();
    if (_ownsController) _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.controller == null || widget.initialValue == null,
      'Use either controller or initialValue, not both.',
    );

    final cs = Theme.of(context).colorScheme;
    final disabled = !widget.enabled;
    final showAccent = _focused && widget.enabled;

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      keyboardType: _multiline && widget.keyboardType == null
          ? TextInputType.multiline
          : widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      textAlign: widget.textAlign,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: disabled ? cs.onSurface.withValues(alpha: 0.45) : null,
            height: _multiline ? 1.45 : 1.25,
          ),
      decoration: InputDecoration(
        isDense: !_multiline,
        isCollapsed: false,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        labelText: widget.label,
        hintText: widget.hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: _multiline,
        labelStyle: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 14,
        ),
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(
                widget.prefixIcon,
                size: 20,
                color: showAccent ? cs.primary : cs.onSurfaceVariant,
              ),
        prefixIconConstraints: widget.prefixIcon != null
            ? const BoxConstraints(minWidth: 36, minHeight: 36)
            : null,
        suffixIcon: widget.suffixIcon == null
            ? null
            : Icon(
                widget.suffixIcon,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
        contentPadding: EdgeInsets.symmetric(
          vertical: _multiline ? 10 : 12,
          horizontal: widget.prefixIcon != null ? 0 : 2,
        ),
      ),
    );

    final child = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _multiline ? 0 : 48,
      ),
      child: field,
    );

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: LiquidSurface(
        variant: showAccent ? LiquidVariant.accent : LiquidVariant.inset,
        tint: cs.primary,
        selected: showAccent,
        radius: LiquidTokens.radiusMd,
        padding: EdgeInsets.fromLTRB(
          widget.prefixIcon != null ? 8 : 14,
          _multiline ? 4 : 2,
          14,
          _multiline ? 6 : 2,
        ),
        child: child,
      ),
    );
  }
}
