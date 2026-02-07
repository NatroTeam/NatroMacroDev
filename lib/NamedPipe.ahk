/********************************************
* @Author Myurius
* @Description Class for named pipe communication
********************************************
*/

class NamedPipe {
    static PIPE_ACCESS => {
        DUPLEX: 0x3,
        INBOUND: 0x1,
        OUTBOUND: 0x2
    }
    static FILE_FLAG => {
        FIRST_PIPE_INSTANCE: 0x80000,
        WRITE_THROUGH: 0x8,
        OVERLAPPED: 0x4
    }
    static PIPE_TYPE => {
        BYTE: 0x0,
        MESSAGE: 0x4
    }
    static PIPE_READMODE => {
        BYTE: 0x0,
        MESSAGE: 0x2
    }
    static PIPE_WAIT => 0x0
    static PIPE_NOWAIT => 0x1
    static FILE_FLAG_OVERLAPPED => 0x40000000

    static Create() {

    }

    class Server {

    }

    class Client {

    }
}
