import 'package:flutter/material.dart';
import '../modelos/modelo_evento.dart';

class FormularioEvento extends StatefulWidget {
  final ModeloEvento? evento;
  const FormularioEvento({super.key, this.evento});

  @override
  State<FormularioEvento> createState() => _FormularioEventoState();
}

class _FormularioEventoState extends State<FormularioEvento> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titulo;
  late TextEditingController descripcion;
  DateTime fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    titulo = TextEditingController(text: widget.evento?.titulo ?? '');
    descripcion = TextEditingController(text: widget.evento?.descripcion ?? '');
    fecha = widget.evento?.fecha ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: titulo, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => (v==null||v.isEmpty)?'Requerido':null),
              TextFormField(controller: descripcion, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
              const SizedBox(height: 8),
              Row(children: [
                Text('Fecha: ${fecha.toLocal().toString().split(' ').first}'),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () async {
                  final pick = await showDatePicker(context: context, initialDate: fecha, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (pick != null) setState(()=>fecha = pick);
                }, child: const Text('Seleccionar'))
              ]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final e = ModeloEvento(id: widget.evento?.id, titulo: titulo.text.trim(), descripcion: descripcion.text.trim(), fecha: fecha);
                Navigator.of(context).pop(e);
              }, child: const Text('Guardar'))
            ],
          ),
        ),
      ),
    );
  }
}
