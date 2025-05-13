import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class ShippingCompanyPopup extends StatefulWidget {
  final String selectedCompany;
  final ValueChanged<String> onCompanySelected;

  const ShippingCompanyPopup({
    super.key,
    required this.selectedCompany,
    required this.onCompanySelected,
  });

  @override
  State<ShippingCompanyPopup> createState() => _ShippingCompanyPopupState();
}

class _ShippingCompanyPopupState extends State<ShippingCompanyPopup> {
  late String _selectedCompany;

  @override
  void initState() {
    super.initState();
    _selectedCompany = widget.selectedCompany;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      OrderStrings.selectShippingCompany,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the popup
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // List of shipping companies
              _buildCompanyOption(context, 'Servientrega'),
              _buildCompanyOption(context, 'Inter Rapidisimo'),
              _buildCompanyOption(context, 'Coordinadora'),
              _buildCompanyOption(context, 'DHL'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text(OrderStrings.cancel,
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    onPressed: _selectedCompany != widget.selectedCompany
                        ? () {
                            widget.onCompanySelected(_selectedCompany);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: const Text('Confirmar',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyOption(BuildContext context, String company) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.blue,
        ),
        child: RadioListTile<String>(
          title: Text(company),
          value: company,
          groupValue: _selectedCompany,
          onChanged: (value) {
            setState(() {
              _selectedCompany = value!;
            });
          },
          activeColor: Colors.blue,
          controlAffinity: ListTileControlAffinity
              .trailing, // Moves the radio button to the right
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
