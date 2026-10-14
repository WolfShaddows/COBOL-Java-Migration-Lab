# Toolchain COBOL portable

El GnuCOBOL global preexistente era 2.0 RC2/MinGW de 2016; su `cobc.exe` fallaba al iniciar por una reubicación inválida de DLL. El proyecto ahora usa GnuCOBOL 3.2.0 x64/MSYS2 con GCC 13.1, aislado en `tools/gnucobol-3.2-msys2`. `scripts/run.ps1` configura PATH y variables solo en el proceso de prueba; no cambia la instalación global.

El paquete binario proviene del enlace de distribución de Arnold Trembley, contribuidor mencionado en el foro de GnuCOBOL. Es un build comunitario, no un instalador oficial del proyecto. El archivo `work/GC32M-BDB-x64.7z` pasó el test interno de 7-Zip (sin errores de archivo). SHA-256 local: `02D6D951268C618A8A3AFF83C1C1B843166357BC73DDEB661A1DE0F068783E99`. No se verificó firma criptográfica del proveedor.

La distribución x64 completa ocupa aproximadamente 754 MB descomprimida. Se mantiene dentro de este proyecto para que el script de comparación sea reproducible; no se modificó PATH global. Compilador y toolchain se usan localmente, no se redistribuyen. GnuCOBOL usa GPLv3+ y los componentes incluidos conservan sus licencias; revisar antes de redistribuir.

- [GnuCOBOL 3.2 release files](https://sourceforge.net/projects/gnucobol/files/gnucobol/3.2/)
- [Community Windows builds and setup notes](https://www.arnoldtrembley.com/GnuCOBOL.htm)
- [GnuCOBOL community discussion of 3.2 Windows binaries](https://sourceforge.net/p/gnucobol/discussion/cobol/thread/ba31f300a7/)
