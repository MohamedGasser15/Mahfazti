part of '../screens/home_tab.dart';
// ignore_for_file: annotate_overrides

mixin _HomeTabWidgets on _HomeTabState {
  //#region Skeleton Widgets
  Widget _buildSkeletonAppBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBalanceCard(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonQuickActions(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(2, (index) {
          return Container(
            width: 120,
            height: 60,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonTransactionHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 120,
            height: 18,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Container(
            width: 50,
            height: 14,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonFilters(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonTransactionCard(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      child: Column(
        children: [
          _buildSkeletonAppBar(isDarkMode),
          const SizedBox(height: 10),
          _buildSkeletonBalanceCard(isDarkMode),
          _buildSkeletonQuickActions(isDarkMode),
          _buildSkeletonTransactionHeader(isDarkMode),
          _buildSkeletonFilters(isDarkMode),
          ...List.generate(3, (index) => _buildSkeletonTransactionCard(isDarkMode)),
        ],
      ),
    );
  }
  //#endregion

  //#region UI Builders
  Widget _buildBlurrableNumber(double amount, TextStyle style, bool blurred) {
    final formatted = _formatAmount(amount);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: blurred ? 0 : 8, end: blurred ? 8 : 0),
      duration: const Duration(milliseconds: 300),
      builder: (context, sigma, child) {
        if (sigma == 0) {
          return Text(formatted, style: style);
        }
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Text(formatted, style: style),
        );
      },
    );
  }

  Widget _buildErrorWidget(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.somethingWentWrong,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _loadHomeData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 60,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget _buildTransactionCard(WalletTransaction transaction, bool isDarkMode) {
    final isIncome = transaction.isDeposit;
    final hideService = Provider.of<HideBalanceService>(context, listen: true);
    final locale = Localizations.localeOf(context).languageCode;
    final categoryName = locale == 'ar'
        ? (transaction.categoryNameAr ?? transaction.categoryNameEn ?? '')
        : (transaction.categoryNameEn ?? transaction.categoryNameAr ?? '');

    return Slidable(
      key: Key('transaction_${transaction.id}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) => _showEditTransactionDialog(transaction),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Container(
              width: 80,
              margin: const EdgeInsets.fromLTRB(4, 4, 4, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.2),
                    Colors.blue.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          color: isDarkMode ? Colors.white : Colors.blue[800],
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.edit,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.blue[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) => _showDeleteConfirmationDialog(transaction),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Container(
              width: 80,
              margin: const EdgeInsets.fromLTRB(4, 4, 4, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.2),
                    Colors.red.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.red.withValues(alpha: 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          color: isDarkMode ? Colors.white : Colors.red[800],
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.delete,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.red[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isIncome
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction.icon,
                color: isIncome ? Colors.green[800] : Colors.red[800],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryName • ${_formatDate(transaction.transactionDate)}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (transaction.description != null &&
                      transaction.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        transaction.description!,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBlurrableNumber(
                  transaction.amount,
                  TextStyle(
                    color: isIncome ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                  hideService.isHidden,
                ),
                Text(
                  _formatDate(transaction.transactionDate),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noTransactions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.addYourFirstTransaction,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
  //#endregion
}
