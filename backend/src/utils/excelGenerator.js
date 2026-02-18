import ExcelJS from 'exceljs';

function crearEstilosExcel(workbook) {
  const headerStyle = {
    font: { bold: true, color: { argb: 'FFFFFFFF' } },
    fill: { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF366092' } },
    alignment: { horizontal: 'center', vertical: 'center', wrapText: true },
    border: {
      top: { style: 'thin' },
      left: { style: 'thin' },
      bottom: { style: 'thin' },
      right: { style: 'thin' },
    },
  };

  const currencyStyle = {
    numFmt: '$#,##0.00',
    border: {
      top: { style: 'thin' },
      left: { style: 'thin' },
      bottom: { style: 'thin' },
      right: { style: 'thin' },
    },
  };

  const numberStyle = {
    numFmt: '#,##0',
    border: {
      top: { style: 'thin' },
      left: { style: 'thin' },
      bottom: { style: 'thin' },
      right: { style: 'thin' },
    },
  };

  const cellStyle = {
    border: {
      top: { style: 'thin' },
      left: { style: 'thin' },
      bottom: { style: 'thin' },
      right: { style: 'thin' },
    },
  };

  return { headerStyle, currencyStyle, numberStyle, cellStyle };
}

export async function exportarProductosExcel(productos) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Productos');
  const { headerStyle, currencyStyle, numberStyle, cellStyle } = crearEstilosExcel(workbook);

  // Encabezados
  const headers = ['ID', 'Nombre', 'Descripción', 'Stock', 'Stock Mínimo', 'Precio Compra', 'Precio Venta', 'Estado'];
  worksheet.columns = headers.map((h) => ({ header: h, width: 15 }));
  worksheet.getRow(1).fill = headerStyle.fill;
  worksheet.getRow(1).font = headerStyle.font;
  worksheet.getRow(1).alignment = headerStyle.alignment;

  // Datos
  productos.forEach((producto, index) => {
    const row = worksheet.addRow([
      producto.id,
      producto.nombre,
      producto.descripcion || '',
      producto.stock,
      producto.stock_minimo,
      parseFloat(producto.precio_compra),
      parseFloat(producto.precio_venta),
      producto.activo ? 'Activo' : 'Inactivo',
    ]);

    row.getCell(6).style = currencyStyle;
    row.getCell(7).style = currencyStyle;
    row.getCell(4).style = numberStyle;
    row.getCell(5).style = numberStyle;

    for (let i = 1; i <= 8; i++) {
      if (i !== 6 && i !== 7 && i !== 4 && i !== 5) {
        row.getCell(i).style = cellStyle;
      }
    }
  });

  // Ancho automático
  worksheet.columns.forEach((col) => {
    col.width = 20;
  });

  return workbook;
}

export async function exportarComprasExcel(compras) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Compras');
  const { headerStyle, currencyStyle, numberStyle, cellStyle } = crearEstilosExcel(workbook);

  const headers = ['ID', 'Producto', 'Cantidad', 'Precio Unitario', 'Total', 'Proveedor', 'Nota', 'Fecha'];
  worksheet.columns = headers.map((h) => ({ header: h, width: 15 }));
  worksheet.getRow(1).fill = headerStyle.fill;
  worksheet.getRow(1).font = headerStyle.font;
  worksheet.getRow(1).alignment = headerStyle.alignment;

  compras.forEach((compra) => {
    const row = worksheet.addRow([
      compra.id,
      compra.nombre_producto || 'N/A',
      compra.cantidad,
      parseFloat(compra.precio_unitario),
      parseFloat(compra.total),
      compra.proveedor || '',
      compra.nota || '',
      new Date(compra.fecha).toLocaleDateString(),
    ]);

    row.getCell(4).style = currencyStyle;
    row.getCell(5).style = currencyStyle;
    row.getCell(3).style = numberStyle;

    for (let i = 1; i <= 8; i++) {
      if (i !== 4 && i !== 5 && i !== 3) {
        row.getCell(i).style = cellStyle;
      }
    }
  });

  // Agregar fila de totales
  const totalRow = worksheet.addRow(['', '', 'TOTAL', '', parseFloat(compras.reduce((sum, c) => sum + parseFloat(c.total), 0))]);
  totalRow.getCell(1).style = headerStyle;
  totalRow.getCell(2).style = headerStyle;
  totalRow.getCell(3).style = headerStyle;
  totalRow.getCell(5).style = { ...currencyStyle, ...headerStyle };

  worksheet.columns.forEach((col) => {
    col.width = 18;
  });

  return workbook;
}

export async function exportarVentasExcel(ventas) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Ventas');
  const { headerStyle, currencyStyle, numberStyle, cellStyle } = crearEstilosExcel(workbook);

  const headers = ['ID', 'Producto', 'Cantidad', 'Precio Unitario', 'Total', 'Nota', 'Fecha'];
  worksheet.columns = headers.map((h) => ({ header: h, width: 15 }));
  worksheet.getRow(1).fill = headerStyle.fill;
  worksheet.getRow(1).font = headerStyle.font;
  worksheet.getRow(1).alignment = headerStyle.alignment;

  ventas.forEach((venta) => {
    const row = worksheet.addRow([
      venta.id,
      venta.nombre_producto || 'N/A',
      venta.cantidad,
      parseFloat(venta.precio_unitario),
      parseFloat(venta.total),
      venta.nota || '',
      new Date(venta.fecha).toLocaleDateString(),
    ]);

    row.getCell(4).style = currencyStyle;
    row.getCell(5).style = currencyStyle;
    row.getCell(3).style = numberStyle;

    for (let i = 1; i <= 7; i++) {
      if (i !== 4 && i !== 5 && i !== 3) {
        row.getCell(i).style = cellStyle;
      }
    }
  });

  // Agregar fila de totales
  const totalRow = worksheet.addRow(['', '', 'TOTAL', '', parseFloat(ventas.reduce((sum, v) => sum + parseFloat(v.total), 0))]);
  totalRow.getCell(1).style = headerStyle;
  totalRow.getCell(2).style = headerStyle;
  totalRow.getCell(3).style = headerStyle;
  totalRow.getCell(5).style = { ...currencyStyle, ...headerStyle };

  worksheet.columns.forEach((col) => {
    col.width = 18;
  });

  return workbook;
}

export async function exportarInversionesExcel(inversiones) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Inversiones');
  const { headerStyle, currencyStyle, cellStyle } = crearEstilosExcel(workbook);

  const headers = ['ID', 'Nombre', 'Descripción', 'Categoría', 'Monto', 'Fecha'];
  worksheet.columns = headers.map((h) => ({ header: h, width: 15 }));
  worksheet.getRow(1).fill = headerStyle.fill;
  worksheet.getRow(1).font = headerStyle.font;
  worksheet.getRow(1).alignment = headerStyle.alignment;

  inversiones.forEach((inversion) => {
    const row = worksheet.addRow([
      inversion.id,
      inversion.nombre,
      inversion.descripcion || '',
      inversion.categoria,
      parseFloat(inversion.monto),
      new Date(inversion.fecha).toLocaleDateString(),
    ]);

    row.getCell(5).style = currencyStyle;

    for (let i = 1; i <= 6; i++) {
      if (i !== 5) {
        row.getCell(i).style = cellStyle;
      }
    }
  });

  // Agregar fila de totales
  const totalRow = worksheet.addRow(['', '', '', 'TOTAL', parseFloat(inversiones.reduce((sum, i) => sum + parseFloat(i.monto), 0))]);
  totalRow.getCell(1).style = headerStyle;
  totalRow.getCell(2).style = headerStyle;
  totalRow.getCell(3).style = headerStyle;
  totalRow.getCell(4).style = headerStyle;
  totalRow.getCell(5).style = { ...currencyStyle, ...headerStyle };

  worksheet.columns.forEach((col) => {
    col.width = 18;
  });

  return workbook;
}

export async function exportarReporteMensualExcel(mes, anio, reporte) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet(`Reporte ${mes}/${anio}`);
  const { headerStyle, currencyStyle } = crearEstilosExcel(workbook);

  // Título
  worksheet.addRow([`Reporte Mensual - ${mes}/${anio}`]);
  worksheet.getRow(1).font = { bold: true, size: 14 };
  worksheet.mergeCells('A1:E1');

  worksheet.addRow([]);

  // Datos principales
  const dataRows = [
    ['Total Ventas', parseFloat(reporte.total_ventas)],
    ['Total Compras', parseFloat(reporte.total_compras)],
    ['Total Inversiones', parseFloat(reporte.total_inversiones)],
    ['Ganancia Neta', parseFloat(reporte.ganancia_neta)],
  ];

  dataRows.forEach(([label, value]) => {
    const row = worksheet.addRow([label, '', '', '', value]);
    row.getCell(1).style = { ...headerStyle, fill: { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFB4C7E7' } } };
    row.getCell(5).style = { ...currencyStyle, ...headerStyle, fill: { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFB4C7E7' } } };
  });

  worksheet.columns = [{ width: 20 }, { width: 15 }, { width: 15 }, { width: 15 }, { width: 15 }];

  return workbook;
}

export async function exportarAuditoriaExcel(auditoria) {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Auditoría');
  const { headerStyle, cellStyle } = crearEstilosExcel(workbook);

  const headers = ['ID', 'Acción', 'Entidad', 'Entidad ID', 'Descripción', 'Fecha'];
  worksheet.columns = headers.map((h) => ({ header: h, width: 15 }));
  worksheet.getRow(1).fill = headerStyle.fill;
  worksheet.getRow(1).font = headerStyle.font;
  worksheet.getRow(1).alignment = headerStyle.alignment;

  auditoria.forEach((registro) => {
    const row = worksheet.addRow([
      registro.id,
      registro.accion,
      registro.entidad,
      registro.entidad_id || '',
      registro.descripcion || '',
      new Date(registro.fecha).toLocaleDateString(),
    ]);

    for (let i = 1; i <= 6; i++) {
      row.getCell(i).style = cellStyle;
    }
  });

  worksheet.columns.forEach((col) => {
    col.width = 18;
  });

  return workbook;
}

export default {
  exportarProductosExcel,
  exportarComprasExcel,
  exportarVentasExcel,
  exportarInversionesExcel,
  exportarReporteMensualExcel,
  exportarAuditoriaExcel,
};
