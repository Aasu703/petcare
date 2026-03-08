import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/shop/cart/presentation/view_model/cart_view_model.dart';
import 'package:petcare/features/shop/cart/presentation/widgets/cart_checkout_bottom_bar.dart';
import 'package:petcare/features/shop/cart/presentation/widgets/cart_empty_state.dart';
import 'package:petcare/features/shop/cart/presentation/widgets/cart_item_list_section.dart';
import 'package:petcare/features/shop/cart/presentation/widgets/cart_summary_card.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarForeground = isDark ? Colors.white : Colors.black87;
    final cart = ref.watch(cartEntityProvider);
    final cartState = ref.watch(cartViewModelProvider);
    final viewModel = ref.read(cartViewModelProvider.notifier);
    final isWideLayout = MediaQuery.sizeOf(context).width >= 900;

    ref.listen(cartViewModelProvider, (previous, next) {
      final error = next.errorMessage;
      final previousError = previous?.errorMessage;
      if (error != null && error.isNotEmpty && error != previousError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.arrow_back_rounded, color: appBarForeground),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(RoutePaths.shop);
            }
          },
        ),
        title: Text(l10n.tr('myCart')),
        backgroundColor: context.surfaceColor,
        foregroundColor: appBarForeground,
        titleTextStyle: TextStyle(
          color: appBarForeground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: appBarForeground),
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: cartState.isCheckingOut
                  ? null
                  : () => _showClearDialog(context, viewModel),
              tooltip: l10n.tr('clearCart'),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? CartEmptyState(
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(RoutePaths.shop);
                }
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideLayout ? 1120 : constraints.maxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isWideLayout
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: constraints.maxHeight - 32,
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.hardEdge,
                                      child: CartItemListSection(
                                        items: cart.items,
                                        onIncrement: viewModel.increaseQuantity,
                                        onDecrement: viewModel.decreaseQuantity,
                                        onRemove: viewModel.removeItem,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: 320,
                                  child: CartSummaryCard(
                                    cart: cart,
                                    isCheckingOut: cartState.isCheckingOut,
                                    onCheckout: () =>
                                        _checkout(context: context, ref: ref),
                                  ),
                                ),
                              ],
                            )
                          : CartItemListSection(
                              items: cart.items,
                              onIncrement: viewModel.increaseQuantity,
                              onDecrement: viewModel.decreaseQuantity,
                              onRemove: viewModel.removeItem,
                            ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isNotEmpty && !isWideLayout
          ? CartCheckoutBottomBar(
              cart: cart,
              isCheckingOut: cartState.isCheckingOut,
              onCheckout: () => _checkout(context: context, ref: ref),
            )
          : null,
    );
  }

  Future<void> _checkout({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final success = await ref.read(cartViewModelProvider.notifier).checkout();
    if (!context.mounted || !success) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tr('orderPlacedSuccess'))));
  }

  void _showClearDialog(BuildContext context, CartViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.tr('clearCartTitle')),
        content: Text(l10n.tr('removeAllItems')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearCart();
              Navigator.pop(context);
            },
            child: Text(
              l10n.tr('clear'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
