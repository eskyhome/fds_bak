program test_mpi
use mpi
implicit none

integer i, size, rank, ierr, N
real :: T_USED(14)
character(80) :: FN_CPU
INTEGER, PARAMETER :: LINE_LENGTH=159
CHARACTER, PARAMETER :: LF=ACHAR(10)
CHARACTER(LEN=LINE_LENGTH+1) :: LINE,HEAD
INTEGER :: RECORD,FH,STATUS(MPI_STATUS_SIZE)

call MPI_INIT (ierr)
call MPI_COMM_SIZE (MPI_COMM_WORLD, size, ierr)
call MPI_COMM_RANK (MPI_COMM_WORLD, rank, ierr)

FN_CPU = 'test_mpi_write.csv'
T_USED = real(rank+1)

CALL MPI_TYPE_CONTIGUOUS(LINE_LENGTH+1,MPI_CHARACTER,RECORD,ierr)
CALL MPI_TYPE_COMMIT(RECORD,ierr)
CALL MPI_FILE_OPEN(MPI_COMM_WORLD,FN_CPU,MPI_MODE_WRONLY+MPI_MODE_CREATE,MPI_INFO_NULL,FH,ierr)
CALL MPI_FILE_SET_VIEW(FH,0_MPI_OFFSET_KIND,RECORD,RECORD,'NATIVE',MPI_INFO_NULL,ierr)

DO N=0,size-1
   IF (rank/=N) CYCLE
   WRITE(0,*) 'rank ',rank,' writes a line'
   WRITE(LINE,'(ES10.3,13(",",ES10.3))') T_USED(1:14)
   LINE(LINE_LENGTH+1:LINE_LENGTH+1) = LF
   CALL MPI_FILE_WRITE_AT(FH,INT(N+1,MPI_OFFSET_KIND),LINE,1,RECORD,STATUS,ierr)
ENDDO

CALL MPI_FILE_CLOSE(FH,ierr)
CALL MPI_TYPE_FREE(RECORD,ierr)
call MPI_FINALIZE (ierr)

end program