import 'package:driver_return/models.dart';
import 'package:flutter/material.dart';

class DeliverPage extends StatefulWidget {
  const DeliverPage({super.key});

  @override
  State<DeliverPage> createState() => _DeliverPageState();
}

class _DeliverPageState extends State<DeliverPage> {
  int _index = 0;
  Customer? _customer;
  final List<Customer> _customers = [
    const Customer(id: 1, address: "Hello world", name: "David Linarez", vat: "V123456789"),
    const Customer(id: 2, address: "Bye world", name: "Jose farias", vat: "V987654321"),
    const Customer(id: 3, address: "Return world", name: "David Bata", vat: "V456789132"),
  ];

  Step getCustomerForm() {
    return Step(
        title: const Text("Cliente"),
        content: Column(
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  leading: const Icon(Icons.search),
                  onTap: () {
                    controller.openView();
                  },
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                return List<ListTile>.generate(3, (int index) {
                  final String item = "item $index";

                  return ListTile(
                    onTap: () => setState(() {
                      _customer = _customers[index];
                      controller.closeView(item);
                    }),
                    title: Text(item),
                  );
                });
              }
            ),
            if (_customer != null)
              getCustomerCard()
          ],
        )
      );
  }

  Widget getCustomerCard() {
    return Card(
      margin: EdgeInsets.only(top: 16),
      child: ListTile(
        title: Text(_customer!.name),
        subtitle: Text("${_customer!.vat}\n${_customer!.address}"),
      ),
    );
  }

  Step getInvoicesForm() {
    return Step(
      title: const Text("Factura"),
      content: const Text("Hello world")
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Pedidos",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)
          ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        elevation: 1,
        currentStep: _index,
        onStepCancel: () {
          if (_index > 0) {
            setState(() {
              _index--;
            });
          }
        },
        onStepContinue: () {
            setState(() {
              _index++;
            });
        },
        steps: <Step>[
          getCustomerForm(),
          getInvoicesForm(),
          const Step(title: Text("Confirmar"), content: Text("Bye world"))
        ]
      ),
    );
  }
}