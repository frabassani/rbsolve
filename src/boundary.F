#include "config.h"

      subroutine boundary (ut,vt,wt)
c VELOCITY boundary conditions

#include "param.h"
      complex*16 ut(nwax+1,2*nwaz+1,0:Nylmem+1)
      complex*16 vt(nwax+1,2*nwaz+1,0:Nylmem+1)
      complex*16 wt(nwax+1,2*nwaz+1,0:Nylmem+1)

#ifdef FREE_SLIP_BOTTOM
* FREE SLIP
      if(iam.eq.1) then
         ut(:,:,0)=ut(:,:,2)
         wt(:,:,0)=wt(:,:,2)         
         vt(:,:,1)=(0.d0,0.d0)
         vt(:,:,0)=vt(:,:,2)
      endif
#else

* NO SLIP
      if(iam.eq.1) then
         ut(:,:,1)=(0.d0,0.d0)
         ut(:,:,0)=-ut(:,:,2)
         wt(:,:,1)=(0.d0,0.d0)
         wt(:,:,0)=-wt(:,:,2)         
         vt(:,:,1)=(0.d0,0.d0)
         vt(:,:,0)=vt(:,:,2)
      endif

#endif

#ifdef FREE_SLIP_TOP
* FREE SLIP
       if(iam.eq.NPROC) then
         ut(:,:,Nyl+1)=ut(:,:,Nyl-1)
         wt(:,:,Nyl+1)=wt(:,:,Nyl-1)
         vt(:,:,Nyl)=(0.d0,0.d0)
         vt(:,:,Nyl+1)=vt(:,:,Nyl-1)
      endif
#else 
* NO SLIP
      if(iam.eq.NPROC) then
         ut(:,:,Nyl)=(0.d0,0.d0)
         ut(:,:,Nyl+1)=-ut(:,:,Nyl-1)
         wt(:,:,Nyl)=(0.d0,0.d0)
         wt(:,:,Nyl+1)=-wt(:,:,Nyl-1)
         vt(:,:,Nyl)=(0.d0,0.d0)
         vt(:,:,Nyl+1)=vt(:,:,Nyl-1)
      endif
#endif
      return
      end  

#ifdef TEMPERATURE
c TEMPERATURE boundary condition

#if defined (PATTERNT_TOP) || defined (PATTERNT_BOTTOM)
      subroutine boundary_temp (tt,yv,ttop,tbot)
#else
      subroutine boundary_temp (tt,yv)
#endif

#include "param.h"

      complex*16 tt(nwax+1,2*nwaz+1,0:Nylmem+1)
#if defined (PATTERNT_TOP) || defined (PATTERNT_BOTTOM)
      complex*16 ttop(nwax+1,2*nwaz+1)
      complex*16 tbot(nwax+1,2*nwaz+1)
#endif
      real*8 yv(0:Ny+1)

#include "allpara.h"

**************** Dirichlet boundary conditions *************
 
#ifdef TEMPERATURE_BOTTOM
#ifdef PATTERNT_BOTTOM
* Temperature pattern at bottom
      if(iam.eq.1) then
          tt(:,:,1)=tbot(:,:)
      endif
#else
* Fixed temperature at bottom
      if(iam.eq.1) then
       tt(:,:,1)=(0.d0,0.d0)
       tt(1,1,1)=( TEMPERATURE_BOTTOM ,0.d0)
      endif
#endif
#endif

#ifdef TEMPERATURE_TOP
#ifdef PATTERNT_TOP
* Temperature pattern at bottom
      if(iam.eq.NPROC) then
          tt(:,:,1)=ttop(:,:)
      endif
#else
* Fixed temperature at top
       if(iam.eq.NPROC) then
         tt(:,:,Nyl)=(0.d0,0.d0)
         tt(1,1,Nyl)=( TEMPERATURE_TOP ,0.d0)
      endif
#endif
#endif

**************** von Neumann boundary conditions *************

#ifdef FLUXT_BOTTOM

#ifdef TEMPERATURE_BOTTOM
* Both Dirichlet and von Neumann conditions are imposed:
* temperatures are fixed also on the inner level j=2 
      if(iam.eq.1) then
       tt(:,:,2)=tt(:,:,1)
       tt(1,1,2)=tt(1,1,1)-FLUXT_BOTTOM*(yv(2)-yv(1))
      endif
#else
* Prescribed flux at bottom
      if(iam.eq.1) then
       tt(:,:,0)=tt(:,:,2)
       tt(1,1,0)=tt(1,1,2)+FLUXT_BOTTOM*(yv(2)-yv(0))
      endif
#endif

#else
#ifdef NOFLUXT_BOTTOM
* No flux at bottom
      if(iam.eq.1) then
         tt(:,:,0)=tt(:,:,2)
      endif
#endif
#endif


#ifdef FLUXT_TOP

#ifdef TEMPERATURE_TOP
      if(iam.eq.NPROC) then
       tt(:,:,Nyl-1)=tt(:,:,Nyl)
       tt(1,1,Nyl-1)=tt(1,1,Nyl)+FLUXT_TOP*(yv(Ny)-yv(Ny-1))
      endif
#else
      if(iam.eq.NPROC) then
       tt(:,:,Nyl+1)=tt(:,:,Nyl-1)
       tt(1,1,Nyl+1)=tt(1,1,Nyl-1)-FLUXT_TOP*(yv(Ny+1)-yv(Ny-1))
      endif
#endif

#else
#ifdef NOFLUXT_TOP
* Prescribed flux at bottom
      if(iam.eq.NPROC) then
         tt(:,:,Nyl+1)=tt(:,:,Nyl-1)
      endif
#endif
#endif

      return
      end
  
#endif


#ifdef SALINITY

      subroutine boundary_scalar (tt,yv)
c SALINITY boundary condition


#include "param.h"


      complex*16 tt(nwax+1,2*nwaz+1,0:Nylmem+1)
      real*8 yv(0:Ny+1)

#include "allpara.h"

**************** Dirichlet boundary conditions *************

#ifdef SCALAR_BOTTOM
* Fixed scalar at bottom
      if(iam.eq.1) then
       tt(:,:,1)=(0.d0,0.d0)
       tt(1,1,1)=( SCALAR_BOTTOM ,0.d0)
      endif
#endif

#ifdef SCALAR_TOP
* Fixed temperature at top
       if(iam.eq.NPROC) then
         tt(:,:,Nyl)=(0.d0,0.d0)
         tt(1,1,Nyl)=( SCALAR_TOP ,0.d0)
      endif
#endif


**************** von Neumann boundary conditions *************

#ifdef FLUXS_BOTTOM

#ifdef SCALAR_BOTTOM
* Both Dirichlet and von Neumann conditions are imposed:
* temperatures are fixed also on the inner level j=2 
      if(iam.eq.1) then
       tt(:,:,2)=tt(:,:,1)
       tt(1,1,2)=tt(1,1,1)-FLUXS_BOTTOM*(yv(2)-yv(1))
      endif
#else
* Prescribed flux at bottom
      if(iam.eq.1) then
       tt(:,:,0)=tt(:,:,2)
       tt(1,1,0)=tt(1,1,2)+FLUXS_BOTTOM*(yv(2)-yv(0))
      endif
#endif

#else
#ifdef NOFLUXS_BOTTOM
* No flux at bottom
      if(iam.eq.1) then
         tt(:,:,0)=tt(:,:,2)
      endif
#endif
#endif


#ifdef FLUXS_TOP

#ifdef SCALAR_TOP
      if(iam.eq.NPROC) then
       tt(:,:,Nyl-1)=tt(:,:,Nyl)
       tt(1,1,Nyl-1)=tt(1,1,Nyl)+FLUXS_TOP*(yv(Ny)-yv(Ny-1))
      endif
#else
      if(iam.eq.NPROC) then
       tt(:,:,Nyl+1)=tt(:,:,Nyl-1)
       tt(1,1,Nyl+1)=tt(1,1,Nyl-1)-FLUXS_TOP*(yv(Ny+1)-yv(Ny-1))
      endif
#endif

#else
#ifdef NOFLUXS_TOP
* Prescribed flux at bottom
      if(iam.eq.NPROC) then
         tt(:,:,Nyl+1)=tt(:,:,Nyl-1)
      endif
#endif
#endif

      return
      end
  
#endif

