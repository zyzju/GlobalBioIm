classdef LinOpHess <  LinOp
    % LinOpHess: Hessian linear operator (finite differences) 
    %
    % :param sz: sizein of the gradient operator
    % :param bc: boundary condition: 'circular' (default), 'zeros', 'mirror'
    %
    % All attributes of parent class :class:`LinOp` are inherited. 
    %
    % **Note-1** When circular boundary conditions are selected, the method
    % makeHtH (or equivalently the composition H'*H) returns a convolution
    % linear operator :class:`LinOp`
    %
    % **Note-2** Only 2D and 3D cases are implemented. The output of the
    % apply() method is: 
    %  - for 2D case: a [sz,3] matrix containing [d^2F/dxx;d^2F/dxy;d^2F/dyy] 
    %  - for 3D case: a [sz,6] matrix containing [d^2F/dxx;d^2F/dxy;d^2F/dxz;d^2F/dyy;d^2F/dyz;d^2F/dzz]
    % These size are the input sizes for the applyAdjoint() method
    %
    % **Example** H = LinOpHess(sz,bc)
    %
    % See also :class:`Map`, :class:`LinOp`
    
	%%    Copyright (C) 2017 
    %     E. Soubies emmanuel.soubies@epfl.ch
	%	 
	%     This program is free software: you can redistribute it and/or modify
	%     it under the terms of the GNU General Public License as published by
	%     the Free Software Foundation, either version 3 of the License, or
	%     (at your option) any later version.
	% 
	%     This program is distributed in the hope that it will be useful,
	%     but WITHOUT ANY WARRANTY; without even the implied warranty of
	%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	%     GNU General Public License for more details.
	% 
	%     You should have received a copy of the GNU General Public License
	%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

    properties (SetAccess = protected,GetAccess = public)
	  ndms;      % number of dimension of the input
      bc;        % boundary condition (default mirror);
    end
    
    %% Constructor
    methods
        function this = LinOpHess(sz,bc)
            if nargin <2, bc='circular'; end
            this.name='LinOpHess';
            this.isInvertible=false;
            this.isDifferentiable=true;
            this.sizein=sz;
            this.ndms = length(this.sizein);
            this.bc=bc;
            switch(this.ndms)
                case(2)
                    this.sizeout=[sz 3];
                case(3)
                    this.sizeout=[sz 6];
            end
        end
    end
    
    %% Core Methods containing implementations (Protected)
    % - apply_(this,x)
    % - applyAdjoint_(this,x)
    % - applyHtH_(this,x)
    % - makeHtH_(this)
    methods (Access = protected)
        function y = apply_(this,x)
            % Reimplemented from parent class :class:`LinOp`.
            y = zeros_(this.sizeout);
            nidx = 0;
            % switch according to the boundary condition
            switch(this.bc)
                case('circular')
                    % switch according to the number of dimension of the input
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                            % xx
                            y(:,:,1)=x([3:end,1,2],:) -2*x([2:end,1],:) + x;
                            % xy
                            y(:,:,2)=x([2:end,1],[2:end,1]) -x([2:end,1],:) - x(:,[2:end,1]) +x;
                            % yy
                            y(:,:,3)=x(:,[3:end,1,2]) -2*x(:,[2:end,1]) + x;
                            % 3 dimensions
                        case(3)
                            % xx
                            y(:,:,:,1)=x([3:end,1,2],:,:) -2*x([2:end,1],:,:) + x;
                            % xy
                            y(:,:,:,2)=x([2:end,1],[2:end,1],:) -x([2:end,1],:,:) - x(:,[2:end,1],:) +x;
                            % xz
                            y(:,:,:,3)=x([2:end,1],:,[2:end,1]) -x([2:end,1],:,:) - x(:,:,[2:end,1]) +x;
                            % yy
                            y(:,:,:,4)=x(:,[3:end,1,2],:) -2*x(:,[2:end,1],:) + x;
                            % yz
                            y(:,:,:,5)=x(:,[2:end,1],[2:end,1]) -x(:,[2:end,1],:) - x(:,:,[2:end,1]) +x;
                            % zz
                            y(:,:,:,6)=x(:,:,[3:end,1,2]) -2*x(:,:,[2:end,1]) + x;
                    end
                case('mirror')
                    % switch according to the number of dimension of the input
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                            % xx
                            y(:,:,1)=x([3:end,end,end-1],:) -2*x([2:end,end],:) + x;
                            % xy
                            y(:,:,2)=x([2:end,end],[2:end,end]) -x([2:end,end],:) - x(:,[2:end,end]) +x;
                            % yy
                            y(:,:,3)=x(:,[3:end,end,end-1]) -2*x(:,[2:end,end]) + x;
                            % 3 dimensions
                        case(3)
                            % xx
                            y(:,:,:,1)=x([3:end,end,end-1],:,:) -2*x([2:end,end],:,:) + x;
                            % xy
                            y(:,:,:,2)=x([2:end,end],[2:end,end],:) -x([2:end,end],:,:) - x(:,[2:end,end],:) +x;
                            % xz
                            y(:,:,:,3)=x([2:end,end],:,[2:end,end]) -x([2:end,end],:,:) - x(:,:,[2:end,end]) +x;
                            % yy
                            y(:,:,:,4)=x(:,[3:end,end,end-1],:) -2*x(:,[2:end,end],:) + x;
                            % yz
                            y(:,:,:,5)=x(:,[2:end,end],[2:end,end]) -x(:,[2:end,end],:) - x(:,:,[2:end,end]) +x;
                            % zz
                            y(:,:,:,6)=x(:,:,[3:end,end,end-1]) -2*x(:,:,[2:end,end]) + x;
                    end
                case('zeros')
                    % switch according to the number of dimension of the input
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                            % xx
                            y(1:end-2,:,1)=x(3:end,:)-2*x(2:end-1,:)+x(1:end-2,:);
                            y(end-1,:,1)=x(end-1,:)-2*x(end,:);
                            y(end,:,1)=x(end,:);
                            % xy
                            y(1:end-1,1:end-1,2)=x(2:end,2:end) - x(2:end,1:end-1)-x(1:end-1,2:end) + x(1:end-1,1:end-1);
                            y(end,1:end-1,2)=x(end,1:end-1)-x(end,2:end);
                            y(1:end-1,end,2)=x(1:end-1,end)-x(2:end,end);
                            y(end,end,2)=x(end,end);
                            % yy
                            y(:,1:end-2,3)=x(:,3:end)-2*x(:,2:end-1)+x(:,1:end-2);
                            y(:,end-1,3)=x(:,end-1)-2*x(:,end);
                            y(:,end,3)=x(:,end);
                            % 3 dimensions
                        case(3)
                            % xx
                            y(1:end-2,:,:,1)=x(3:end,:,:)-2*x(2:end-1,:,:)+x(1:end-2,:,:);
                            y(end-1,:,:,1)=x(end-1,:,:)-2*x(end,:,:);
                            y(end,:,:,1)=x(end,:,:);
                            % xy
                            y(1:end-1,1:end-1,:,2)=x(2:end,2:end,:) - x(2:end,1:end-1,:)-x(1:end-1,2:end,:) + x(1:end-1,1:end-1,:);
                            y(end,1:end-1,:,2)=x(end,1:end-1,:)-x(end,2:end,:);
                            y(1:end-1,end,:,2)=x(1:end-1,end,:)-x(2:end,end,:);
                            y(end,end,:,2)=x(end,end,:);
                            % xz
                            y(1:end-1,:,1:end-1,3)=x(2:end,:,2:end) - x(2:end,:,1:end-1)-x(1:end-1,:,2:end) + x(1:end-1,:,1:end-1);
                            y(end,:,1:end-1,3)=x(end,:,1:end-1)-x(end,:,2:end);
                            y(1:end-1,:,end,3)=x(1:end-1,:,end)-x(2:end,:,end);
                            y(end,:,end,3)=x(end,:,end);
                            % yy
                            y(:,1:end-2,:,4)=x(:,3:end,:)-2*x(:,2:end-1,:)+x(:,1:end-2,:);
                            y(:,end-1,:,4)=x(:,end-1,:)-2*x(:,end,:);
                            y(:,end,:,4)=x(:,end,:);
                            % yz
                            y(:,1:end-1,1:end-1,5)=x(:,2:end,2:end) - x(:,2:end,1:end-1)-x(:,1:end-1,2:end) + x(:,1:end-1,1:end-1);
                            y(:,end,1:end-1,5)=x(:,end,1:end-1)-x(:,end,2:end);
                            y(:,1:end-1,end,5)=x(:,1:end-1,end)-x(:,2:end,end);
                            y(:,end,end,5)=x(:,end,end);
                            % zz
                            y(:,:,1:end-2,6)=x(:,:,3:end)-2*x(:,:,2:end-1)+x(:,:,1:end-2);
                            y(:,:,end-1,6)=x(:,:,end-1)-2*x(:,:,end);
                            y(:,:,end,6)=x(:,:,end);
                    end
            end
        end
        function y = applyAdjoint_(this,x)
            % Reimplemented from parent class :class:`LinOp`.
            nidx = 0;
            y = zeros_(this.sizein);
            % switch according to the boundary condition
            switch(this.bc)
                case('circular')
                    % switch according to the number of dimension of the input
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                            y=x([end-1,end,1:end-2],:,1)-2*x([end,1:end-1],:,1) +x(:,:,1) +x(:,[end-1,end,1:end-2],3)-2*x(:,[end,1:end-1],3) +x(:,:,3) + ...
                                x([end,1:end-1],[end,1:end-1],2) -  x(:,[end,1:end-1],2)  -  x([end,1:end-1],:,2) + x(:,:,2);
                            % 3 dimension
                        case(3)
                            y=x([end-1,end,1:end-2],:,:,1)-2*x([end,1:end-1],:,:,1) +x(:,:,:,1) +x(:,[end-1,end,1:end-2],:,4)-2*x(:,[end,1:end-1],:,4) +x(:,:,:,4) + ...
                                +x(:,:,[end-1,end,1:end-2],6)-2*x(:,:,[end,1:end-1],6) +x(:,:,:,6) +x([end,1:end-1],[end,1:end-1],:,2) -  x(:,[end,1:end-1],:,2)  -  x([end,1:end-1],:,:,2) + x(:,:,:,2) +...
                                +x([end,1:end-1],:,[end,1:end-1],3) -  x(:,:,[end,1:end-1],3)  -  x([end,1:end-1],:,:,3) + x(:,:,:,3) + ...
                                x(:,[end,1:end-1],[end,1:end-1],5) -  x(:,[end,1:end-1],:,5)  -  x(:,:,[end,1:end-1],5) + x(:,:,:,5);
                    end
                case('mirror')
                    % switch according to the number of dimension of the input
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                            % xx
                            y(1,:)=y(1,:) + x(1,:,1);
                            y(2,:)=y(2,:) + x(2,:,1) - 2*x(1,:,1);
                            y(3:end-2,:)=y(3:end-2,:) + x(1:end-4,:,1) - 2*x(2:end-3,:,1) + x(3:end-2,:,1);
                            y(end-1,:)=y(end-1,:) + x(end-3,:,1)-2*x(end-2,:,1)+x(end-1,:,1)+x(end,:,1);
                            y(end,:)=y(end,:) + x(end-2,:,1) - x(end-1,:,1) - x(end,:,1);
                            % xy
                            y(2:end-1,2:end-1)=y(2:end-1,2:end-1) + x(1:end-2,1:end-2,2) - x(1:end-2,2:end-1,2) - x(2:end-1,1:end-2,2) + x(2:end-1,2:end-1,2);
                            y(2:end-1,1) = y(2:end-1,1) -x(1:end-2,1,2)+ x(2:end-1,1,2);
                            y(1,2:end-1) = y(1,2:end-1) -x(1,1:end-2,2)+ x(1,2:end-1,2);
                            y(2:end-1,end) = y(2:end-1,end) -x(2:end-1,end-1,2)+ x(1:end-2,end-1,2);
                            y(end,2:end-1) = y(end,2:end-1) -x(end-1,2:end-1,2)+ x(end-1,1:end-2,2);
                            y(1,1)=y(1,1)+x(1,1,2);
                            y(end,end)=y(end,end)+x(end-1,end-1,2);
                            y(1,end)=y(1,end)-x(1,end-1,2);
                            y(end,1)=y(end,1)-x(end-1,1,2);
                            % yy
                            y(:,1)=y(:,1) + x(:,1,3);
                            y(:,2)=y(:,2) + x(:,2,3) - 2*x(:,1,3);
                            y(:,3:end-2)=y(:,3:end-2) + x(:,1:end-4,3) - 2*x(:,2:end-3,3) + x(:,3:end-2,3);
                            y(:,end-1)=y(:,end-1) + x(:,end-3,3)-2*x(:,end-2,3)+x(:,end-1,3)+x(:,end,3);
                            y(:,end)=y(:,end) + x(:,end-2,3) - x(:,end-1,3) - x(:,end,3);
                            % 3 dimension
                        case(3)
                            % xx
                            y(1,:,:)=y(1,:,:) + x(1,:,:,1);
                            y(2,:,:)=y(2,:,:) + x(2,:,:,1) - 2*x(1,:,:,1);
                            y(3:end-2,:,:)=y(3:end-2,:,:) + x(1:end-4,:,:,1) - 2*x(2:end-3,:,:,1) + x(3:end-2,:,:,1);
                            y(end-1,:,:)=y(end-1,:,:) + x(end-3,:,:,1)-2*x(end-2,:,:,1)+x(end-1,:,:,1)+x(end,:,:,1);
                            y(end,:,:)=y(end,:,:) + x(end-2,:,:,1) - x(end-1,:,:,1) - x(end,:,:,1);
                            % xy
                            y(2:end-1,2:end-1,:)=y(2:end-1,2:end-1,:) + x(1:end-2,1:end-2,:,2) - x(1:end-2,2:end-1,:,2) - x(2:end-1,1:end-2,:,2) + x(2:end-1,2:end-1,:,2);
                            y(2:end-1,1,:) = y(2:end-1,1,:) -x(1:end-2,1,:,2)+ x(2:end-1,1,:,2);
                            y(1,2:end-1,:) = y(1,2:end-1,:) -x(1,1:end-2,:,2)+ x(1,2:end-1,:,2);
                            y(2:end-1,end,:) = y(2:end-1,end,:) -x(2:end-1,end-1,:,2)+ x(1:end-2,end-1,:,2);
                            y(end,2:end-1,:) = y(end,2:end-1,:) -x(end-1,2:end-1,:,2)+ x(end-1,1:end-2,:,2);
                            y(1,1,:)=y(1,1,:)+x(1,1,:,2);
                            y(end,end,:)=y(end,end,:)+x(end-1,end-1,:,2);
                            y(1,end,:)=y(1,end,:)-x(1,end-1,:,2);
                            y(end,1,:)=y(end,1,:)-x(end-1,1,:,2);
                            % xz
                            y(2:end-1,:,2:end-1)=y(2:end-1,:,2:end-1) + x(1:end-2,:,1:end-2,3) - x(1:end-2,:,2:end-1,3) - x(2:end-1,:,1:end-2,3) + x(2:end-1,:,2:end-1,3);
                            y(2:end-1,:,1) = y(2:end-1,:,1) -x(1:end-2,:,1,3)+ x(2:end-1,:,1,3);
                            y(1,:,2:end-1) = y(1,:,2:end-1) -x(1,:,1:end-2,3)+ x(1,:,2:end-1,3);
                            y(2:end-1,:,end) = y(2:end-1,:,end) -x(2:end-1,:,end-1,3)+ x(1:end-2,:,end-1,3);
                            y(end,:,2:end-1) = y(end,:,2:end-1) -x(end-1,:,2:end-1,3)+ x(end-1,:,1:end-2,3);
                            y(1,:,1)=y(1,:,1)+x(1,:,1,3);
                            y(end,:,end)=y(end,:,end)+x(end-1,:,end-1,3);
                            y(1,:,end)=y(1,:,end)-x(1,:,end-1,3);
                            y(end,:,1)=y(end,:,1)-x(end-1,:,1,3);
                            % yy
                            y(:,1,:)=y(:,1,:) + x(:,1,:,4);
                            y(:,2,:)=y(:,2,:) + x(:,2,:,4) - 2*x(:,1,:,4);
                            y(:,3:end-2,:)=y(:,3:end-2,:) + x(:,1:end-4,:,4) - 2*x(:,2:end-3,:,4) + x(:,3:end-2,:,4);
                            y(:,end-1,:)=y(:,end-1,:) + x(:,end-3,:,4)-2*x(:,end-2,:,4)+x(:,end-1,:,4)+x(:,end,:,4);
                            y(:,end,:)=y(:,end,:) + x(:,end-2,:,4) - x(:,end-1,:,4) - x(:,end,:,4);
                            % yz
                            y(:,2:end-1,2:end-1)=y(:,2:end-1,2:end-1) + x(:,1:end-2,1:end-2,5) - x(:,1:end-2,2:end-1,5) - x(:,2:end-1,1:end-2,5) + x(:,2:end-1,2:end-1,5);
                            y(:,2:end-1,1) = y(:,2:end-1,1) -x(:,1:end-2,1,5)+ x(:,2:end-1,1,5);
                            y(:,1,2:end-1) = y(:,1,2:end-1) -x(:,1,1:end-2,5)+ x(:,1,2:end-1,5);
                            y(:,2:end-1,end) = y(:,2:end-1,end) -x(:,2:end-1,end-1,5)+ x(:,1:end-2,end-1,5);
                            y(:,end,2:end-1) = y(:,end,2:end-1) -x(:,end-1,2:end-1,5)+ x(:,end-1,1:end-2,5);
                            y(:,1,1)=y(:,1,1)+x(:,1,1,5);
                            y(:,end,end)=y(:,end,end)+x(:,end-1,end-1,5);
                            y(:,1,end)=y(:,1,end)-x(:,1,end-1,5);
                            y(:,end,1)=y(:,end,1)-x(:,end-1,1,5);
                            % zz
                            y(:,:,1)=y(:,:,1) + x(:,:,1,6);
                            y(:,:,2)=y(:,:,2) + x(:,:,2,6) - 2*x(:,:,1,6);
                            y(:,:,3:end-2)=y(:,:,3:end-2) + x(:,:,1:end-4,6) - 2*x(:,:,2:end-3,6) + x(:,:,3:end-2,6);
                            y(:,:,end-1)=y(:,:,end-1) + x(:,:,end-3,6)-2*x(:,:,end-2,6)+x(:,:,end-1,6)+x(:,:,end,6);
                            y(:,:,end)=y(:,:,end) + x(:,:,end-2,6) - x(:,:,end-1,6) - x(:,:,end,6);
                    end
                case('zeros')
                    % switch according to the number of dimension of the input
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                            % xx
                            y(1,:)=y(1,:) + x(1,:,1);
                            y(2,:)=y(2,:) + x(2,:,1) - 2*x(1,:,1);
                            y(3:end,:)=y(3:end,:) + x(1:end-2,:,1) - 2*x(2:end-1,:,1) + x(3:end,:,1);
                            % xy
                            y(2:end,2:end)=y(2:end,2:end) + x(1:end-1,1:end-1,2) - x(1:end-1,2:end,2) - x(2:end,1:end-1,2) + x(2:end,2:end,2);
                            y(2:end,1) = y(2:end,1) -x(1:end-1,1,2)+ x(2:end,1,2);
                            y(1,2:end) = y(1,2:end) - x(1,1:end-1,2) + x(1,2:end,2);
                            y(1,1)=y(1,1)+x(1,1,2);
                            % yy
                            y(:,1)=y(:,1) + x(:,1,3);
                            y(:,2)=y(:,2) + x(:,2,3) - 2*x(:,1,3);
                            y(:,3:end)=y(:,3:end) + x(:,1:end-2,3) - 2*x(:,2:end-1,3) + x(:,3:end,3);
                            % 3 dimensions
                        case(3)
                            % xx
                            y(1,:,:)=y(1,:,:) + x(1,:,:,1);
                            y(2,:,:)=y(2,:,:) + x(2,:,:,1) - 2*x(1,:,:,1);
                            y(3:end,:,:)=y(3:end,:,:) + x(1:end-2,:,:,1) - 2*x(2:end-1,:,:,1) + x(3:end,:,:,1);
                            % xy
                            y(2:end,2:end,:)=y(2:end,2:end,:) + x(1:end-1,1:end-1,:,2) - x(1:end-1,2:end,:,2) - x(2:end,1:end-1,:,2) + x(2:end,2:end,:,2);
                            y(2:end,1,:) = y(2:end,1,:) -x(1:end-1,1,:,2)+ x(2:end,1,:,2);
                            y(1,2:end,:) = y(1,2:end,:) - x(1,1:end-1,:,2) + x(1,2:end,:,2);
                            y(1,1,:)=y(1,1,:)+x(1,1,:,2);
                            % xz
                            y(2:end,:,2:end)=y(2:end,:,2:end) + x(1:end-1,:,1:end-1,3) - x(1:end-1,:,2:end,3) - x(2:end,:,1:end-1,3) + x(2:end,:,2:end,3);
                            y(2:end,:,1) = y(2:end,:,1) -x(1:end-1,:,1,3)+ x(2:end,:,1,3);
                            y(1,:,2:end) = y(1,:,2:end) - x(1,:,1:end-1,3) + x(1,:,2:end,3);
                            y(1,:,1)=y(1,:,1)+x(1,:,1,3);
                            % yy
                            y(:,1,:)=y(:,1,:) + x(:,1,:,4);
                            y(:,2,:)=y(:,2,:) + x(:,2,:,4) - 2*x(:,1,:,4);
                            y(:,3:end,:)=y(:,3:end,:) + x(:,1:end-2,:,4) - 2*x(:,2:end-1,:,4) + x(:,3:end,:,4);
                            % yz
                            y(:,2:end,2:end)=y(:,2:end,2:end) + x(:,1:end-1,1:end-1,5) - x(:,1:end-1,2:end,5) - x(:,2:end,1:end-1,5) + x(:,2:end,2:end,5);
                            y(:,2:end,1) = y(:,2:end,1) -x(:,1:end-1,1,5)+ x(:,2:end,1,5);
                            y(:,1,2:end) = y(:,1,2:end) - x(:,1,1:end-1,5) + x(:,1,2:end,5);
                            y(:,1,1)=y(:,1,1)+x(:,1,1,5);
                            % zz
                            y(:,:,1)=y(:,:,1) + x(:,:,1,6);
                            y(:,:,2)=y(:,:,2) + x(:,:,2,6) - 2*x(:,:,1,6);
                            y(:,:,3:end)=y(:,:,3:end) + x(:,:,1:end-2,6) - 2*x(:,:,2:end-1,6) + x(:,:,3:end,6);
                            
                    end
            end
        end		
		function y = applyHtH_(this,x)
            % Reimplemented from parent class :class:`LinOp`.
            nidx = 0;
            y = zeros_(this.sizein);
            % switch according to the number of dimension of the input
            % Emmanuel : FOR LARGE IMAGES IT SEEMS THAT THIS IMPLEMENTATION OF HTH DO NOT MAKE ANY 
            % IMPROVEMENT WITH RESPECT TO SUCCESSIVELY APPLY  H AND HT
            switch(this.bc)
                case('circular')
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                        	y=16*x-6*(x([end,1:end-1],:) + x([2:end,1],:) + x(:,[end,1:end-1]) + x(:,[2:end,1])) + x([end-1,end,1:end-2],:) + x(:,[end-1,end,1:end-2]) + x([3:end,1,2],:) + x(:,[3:end,1,2]) + ...
                            	x([2:end,1],[2:end,1]) + x([end,1:end-1],[2:end,1]) + x([2:end,1],[end,1:end-1]) + x([end,1:end-1],[end,1:end-1]);
                        % 3 dimensions
                        case(3)
                            y=30*x-8*(x([end,1:end-1],:,:) + x([2:end,1],:,:) + x(:,[end,1:end-1],:) + x(:,[2:end,1],:) + x(:,:,[end,1:end-1]) + x(:,:,[2:end,1])) +...
                                x([end-1,end,1:end-2],:,:) + x(:,[end-1,end,1:end-2],:) + x(:,:,[end-1,end,1:end-2]) + ...
                                x([3:end,1,2],:,:) + x(:,[3:end,1,2],:) + x(:,:,[3:end,1,2]) + ...
                                x([2:end,1],[2:end,1],:) + x([end,1:end-1],[2:end,1],:) + x([2:end,1],[end,1:end-1],:) + x([end,1:end-1],[end,1:end-1],:) + ...
                                x([2:end,1],:,[2:end,1]) + x([end,1:end-1],:,[2:end,1]) + x([2:end,1],:,[end,1:end-1]) + x([end,1:end-1],:,[end,1:end-1]) + ...
                                x(:,[2:end,1],[2:end,1]) + x(:,[end,1:end-1],[2:end,1]) + x(:,[2:end,1],[end,1:end-1]) + x(:,[end,1:end-1],[end,1:end-1]);
                    end
                case('mirror')
                    y=adjoint(this,apply(this,x));
                    % TODO: Implements a faster version ?
                case('zeros')
                    switch(this.ndms)
                        % 2 dimension
                        case(2)
                            % xx
                            y(1,:)= y(1,:) + x(3,:) -2*x(2,:) + x(1,:);
                            y(2,:)=y(2,:) + x(4,:) - 4*x(3,:) + 5*x(2,:) - 2*x(1,:);
                            y(3:end-2,:)=y(3:end-2,:) + 6*x(3:end-2,:) - 4*x(4:end-1,:) + x(5:end,:) - 4*x(2:end-3,:) + x(1:end-4,:);
                            y(end-1,:)=y(end-1,:) + 6*x(end-1,:) - 4*x(end-2,:) - 4*x(end,:) + x(end-3,:);
                            y(end,:)=y(end,:)+6*x(end,:)-4*x(end-1,:) + x(end-2,:);
                            % xy
                            y(1,1)=y(1,1) + x(2,2) - x(2,1) - x(1,2) + x(1,1);
                            y(2:end-1,2:end-1)=y(2:end-1,2:end-1) + 4*x(2:end-1,2:end-1) - 2*x(2:end-1,1:end-2) - 2*x(1:end-2,2:end-1) -2*x(2:end-1,3:end) - 2*x(3:end,2:end-1) + x(1:end-2,1:end-2) + x(1:end-2,3:end) + x(3:end,1:end-2) + x(3:end,3:end);
                            y(1,2:end-1) = y(1,2:end-1) - 2*x(2,2:end-1) + 2*x(1,2:end-1) - x(1,3:end) + x(2,1:end-2) + x(2,3:end) - x(1,1:end-2);
                            y(2:end-1,1) = y(2:end-1,1) - 2*x(2:end-1,2) + 2*x(2:end-1,1) - x(3:end,1) + x(1:end-2,2) + x(3:end,2) - x(1:end-2,1);
                            y(end,2:end-1)=y(end,2:end-1) + 4*x(end,2:end-1) - 2*x(end,1:end-2) - 2*x(end,3:end) -2*x(end-1,2:end-1) + x(end-1,1:end-2) + x(end-1,3:end);
                            y(2:end-1,end)=y(2:end-1,end) + 4*x(2:end-1,end) - 2*x(1:end-2,end) - 2*x(3:end,end) -2*x(2:end-1,end-1) + x(1:end-2,end-1) + x(3:end,end-1);
                            y(1,end)=y(1,end) + 2*x(1,end) + x(2,end-1) -2*x(2,end) - x(1,end-1);
                            y(end,1)=y(end,1) + 2*x(end,1) + x(end-1,2) -2*x(end,2) - x(end-1,1);
                            y(end,end)=y(end,end) + 4*x(end,end) - 2*x(end,end-1) -2*x(end-1,end) + x(end-1,end-1);
                            % yy
                            y(:,1)= y(:,1) + x(:,3) -2*x(:,2) + x(:,1);
                            y(:,2)=y(:,2) + x(:,4) - 4*x(:,3) + 5*x(:,2) - 2*x(:,1);
                            y(:,3:end-2)=y(:,3:end-2) + 6*x(:,3:end-2) - 4*x(:,4:end-1) + x(:,5:end) - 4*x(:,2:end-3) + x(:,1:end-4);
                            y(:,end-1)=y(:,end-1) + 6*x(:,end-1) - 4*x(:,end-2) - 4*x(:,end) + x(:,end-3);
                            y(:,end)=y(:,end)+6*x(:,end)-4*x(:,end-1) + x(:,end-2);
                            % 3 dimensions
                        case(3)
                            % xx
                            y(1,:,:)= y(1,:,:) + x(3,:,:) -2*x(2,:,:) + x(1,:,:);
                            y(2,:,:)=y(2,:,:) + x(4,:,:) - 4*x(3,:,:) + 5*x(2,:,:) - 2*x(1,:,:);
                            y(3:end-2,:,:)=y(3:end-2,:,:) + 6*x(3:end-2,:,:) - 4*x(4:end-1,:,:) + x(5:end,:,:) - 4*x(2:end-3,:,:) + x(1:end-4,:,:);
                            y(end-1,:,:)=y(end-1,:,:) + 6*x(end-1,:,:) - 4*x(end-2,:,:) - 4*x(end,:,:) + x(end-3,:,:);
                            y(end,:,:)=y(end,:,:)+6*x(end,:,:)-4*x(end-1,:,:) + x(end-2,:,:);
                            % xy
                            y(1,1,:)=y(1,1,:) + x(2,2,:) - x(2,1,:) - x(1,2,:) + x(1,1,:);
                            y(2:end-1,2:end-1,:)=y(2:end-1,2:end-1,:) + 4*x(2:end-1,2:end-1,:) - 2*x(2:end-1,1:end-2,:) - 2*x(1:end-2,2:end-1,:) -2*x(2:end-1,3:end,:) - 2*x(3:end,2:end-1,:) + x(1:end-2,1:end-2,:) + x(1:end-2,3:end,:) + x(3:end,1:end-2,:) + x(3:end,3:end,:);
                            y(1,2:end-1,:) = y(1,2:end-1,:) - 2*x(2,2:end-1,:) + 2*x(1,2:end-1,:) - x(1,3:end,:) + x(2,1:end-2,:) + x(2,3:end,:) - x(1,1:end-2,:);
                            y(2:end-1,1,:) = y(2:end-1,1,:) - 2*x(2:end-1,2,:) + 2*x(2:end-1,1,:) - x(3:end,1,:) + x(1:end-2,2,:) + x(3:end,2,:) - x(1:end-2,1,:);
                            y(end,2:end-1,:)=y(end,2:end-1,:) + 4*x(end,2:end-1,:) - 2*x(end,1:end-2,:) - 2*x(end,3:end,:) -2*x(end-1,2:end-1,:) + x(end-1,1:end-2,:) + x(end-1,3:end,:);
                            y(2:end-1,end,:)=y(2:end-1,end,:) + 4*x(2:end-1,end,:) - 2*x(1:end-2,end,:) - 2*x(3:end,end,:) -2*x(2:end-1,end-1,:) + x(1:end-2,end-1,:) + x(3:end,end-1,:);
                            y(1,end,:)=y(1,end,:) + 2*x(1,end,:) + x(2,end-1,:) -2*x(2,end,:) - x(1,end-1,:);
                            y(end,1,:)=y(end,1,:) + 2*x(end,1,:) + x(end-1,2,:) -2*x(end,2,:) - x(end-1,1,:);
                            y(end,end,:)=y(end,end,:) + 4*x(end,end,:) - 2*x(end,end-1,:) -2*x(end-1,end,:) + x(end-1,end-1,:);
                            % xz
                            y(1,:,1)=y(1,:,1) + x(2,:,2) - x(2,:,1) - x(1,:,2) + x(1,:,1);
                            y(2:end-1,:,2:end-1)=y(2:end-1,:,2:end-1) + 4*x(2:end-1,:,2:end-1) - 2*x(2:end-1,:,1:end-2) - 2*x(1:end-2,:,2:end-1) -2*x(2:end-1,:,3:end) - 2*x(3:end,:,2:end-1) + x(1:end-2,:,1:end-2) + x(1:end-2,:,3:end) + x(3:end,:,1:end-2) + x(3:end,:,3:end);
                            y(1,:,2:end-1) = y(1,:,2:end-1) - 2*x(2,:,2:end-1) + 2*x(1,:,2:end-1) - x(1,:,3:end) + x(2,:,1:end-2) + x(2,:,3:end) - x(1,:,1:end-2);
                            y(2:end-1,:,1) = y(2:end-1,:,1) - 2*x(2:end-1,:,2) + 2*x(2:end-1,:,1) - x(3:end,:,1) + x(1:end-2,:,2) + x(3:end,:,2) - x(1:end-2,:,1);
                            y(end,:,2:end-1)=y(end,:,2:end-1) + 4*x(end,:,2:end-1) - 2*x(end,:,1:end-2) - 2*x(end,:,3:end) -2*x(end-1,:,2:end-1) + x(end-1,:,1:end-2) + x(end-1,:,3:end);
                            y(2:end-1,:,end)=y(2:end-1,:,end) + 4*x(2:end-1,:,end) - 2*x(1:end-2,:,end) - 2*x(3:end,:,end) -2*x(2:end-1,:,end-1) + x(1:end-2,:,end-1) + x(3:end,:,end-1);
                            y(1,:,end)=y(1,:,end) + 2*x(1,:,end) + x(2,:,end-1) -2*x(2,:,end) - x(1,:,end-1);
                            y(end,:,1)=y(end,:,1) + 2*x(end,:,1) + x(end-1,:,2) -2*x(end,:,2) - x(end-1,:,1);
                            y(end,:,end)=y(end,:,end) + 4*x(end,:,end) - 2*x(end,:,end-1) -2*x(end-1,:,end) + x(end-1,:,end-1);
                            % yy
                            y(:,1,:)= y(:,1,:) + x(:,3,:) -2*x(:,2,:) + x(:,1,:);
                            y(:,2,:)=y(:,2,:) + x(:,4,:) - 4*x(:,3,:) + 5*x(:,2,:) - 2*x(:,1,:);
                            y(:,3:end-2,:)=y(:,3:end-2,:) + 6*x(:,3:end-2,:) - 4*x(:,4:end-1,:) + x(:,5:end,:) - 4*x(:,2:end-3,:) + x(:,1:end-4,:);
                            y(:,end-1,:)=y(:,end-1,:) + 6*x(:,end-1,:) - 4*x(:,end-2,:) - 4*x(:,end,:) + x(:,end-3,:);
                            y(:,end,:)=y(:,end,:)+6*x(:,end,:)-4*x(:,end-1,:) + x(:,end-2,:);
                            % yz
                            y(:,1,1)=y(:,1,1) + x(:,2,2) - x(:,2,1) - x(:,1,2) + x(:,1,1);
                            y(:,2:end-1,2:end-1)=y(:,2:end-1,2:end-1) + 4*x(:,2:end-1,2:end-1) - 2*x(:,2:end-1,1:end-2) - 2*x(:,1:end-2,2:end-1) -2*x(:,2:end-1,3:end) - 2*x(:,3:end,2:end-1) + x(:,1:end-2,1:end-2) + x(:,1:end-2,3:end) + x(:,3:end,1:end-2) + x(:,3:end,3:end);
                            y(:,1,2:end-1) = y(:,1,2:end-1) - 2*x(:,2,2:end-1) + 2*x(:,1,2:end-1) - x(:,1,3:end) + x(:,2,1:end-2) + x(:,2,3:end) - x(:,1,1:end-2);
                            y(:,2:end-1,1) = y(:,2:end-1,1) - 2*x(:,2:end-1,2) + 2*x(:,2:end-1,1) - x(:,3:end,1) + x(:,1:end-2,2) + x(:,3:end,2) - x(:,1:end-2,1);
                            y(:,end,2:end-1)=y(:,end,2:end-1) + 4*x(:,end,2:end-1) - 2*x(:,end,1:end-2) - 2*x(:,end,3:end) -2*x(:,end-1,2:end-1) + x(:,end-1,1:end-2) + x(:,end-1,3:end);
                            y(:,2:end-1,end)=y(:,2:end-1,end) + 4*x(:,2:end-1,end) - 2*x(:,1:end-2,end) - 2*x(:,3:end,end) -2*x(:,2:end-1,end-1) + x(:,1:end-2,end-1) + x(:,3:end,end-1);
                            y(:,1,end)=y(:,1,end) + 2*x(:,1,end) + x(:,2,end-1) -2*x(:,2,end) - x(:,1,end-1);
                            y(:,end,1)=y(:,end,1) + 2*x(:,end,1) + x(:,end-1,2) -2*x(:,end,2) - x(:,end-1,1);
                            y(:,end,end)=y(:,end,end) + 4*x(:,end,end) - 2*x(:,end,end-1) -2*x(:,end-1,end) + x(:,end-1,end-1);
                            % zz
                            y(:,:,1)= y(:,:,1) + x(:,:,3) -2*x(:,:,2) + x(:,:,1);
                            y(:,:,2)=y(:,:,2) + x(:,:,4) - 4*x(:,:,3) + 5*x(:,:,2) - 2*x(:,:,1);
                            y(:,:,3:end-2)=y(:,:,3:end-2) + 6*x(:,:,3:end-2) - 4*x(:,:,4:end-1) + x(:,:,5:end) - 4*x(:,:,2:end-3) + x(:,:,1:end-4);
                            y(:,:,end-1)=y(:,:,end-1) + 6*x(:,:,end-1) - 4*x(:,:,end-2) - 4*x(:,:,end) + x(:,:,end-3);
                            y(:,:,end)=y(:,:,end)+6*x(:,:,end)-4*x(:,:,end-1) + x(:,:,end-2);
                    end
            end
        end
        function M = makeHtH_(this)
            % Reimplemented from parent class :class:`LinOp`.
            if strcmp(this.bc,'circular')&&(this.ndms<=3)
                fHtH=zeros_(this.sizein);
                switch(this.ndms)
                    case(2), fHtH(1,1)=16;fHtH(1,2)=-6;fHtH(2,1)=-6;fHtH(end,1)=-6;fHtH(1,end)=-6;fHtH(1,3)=1;
                        fHtH(2,2)=1;fHtH(3,1)=1;fHtH(end-1,1)=1;fHtH(end,2)=1;fHtH(2,end)=1;fHtH(1,end-1)=1;
                        fHtH(end,end)=1;
                    case(3), fHtH(1,1,1)=30;fHtH(1,2,1)=-8;fHtH(2,1,1)=-8;fHtH(end,1,1)=-8;fHtH(1,end,1)=-8;fHtH(1,1,2)=-8;fHtH(1,1,end)=-8;
                        fHtH(1,3,1)=1;fHtH(3,1,1)=1;fHtH(2,2,1)=1;fHtH(end-1,1,1)=1;fHtH(end,2,1)=1;fHtH(2,end,1)=1;fHtH(1,end-1,1)=1;
                        fHtH(end,end,1)=1;fHtH(2,1,2)=1;fHtH(1,2,2)=1;fHtH(end,1,2)=1; fHtH(1,end,2)=1;fHtH(2,1,end)=1;fHtH(1,2,end)=1;
                        fHtH(1,1,end-1)=1;fHtH(end,1,end)=1;fHtH(3,1,1)=1;fHtH(1,1,3)=1;fHtH(1,end,end)=1;
                end
                M=LinOpConv(fftn(fHtH));
            else
                M=makeHtH_@LinOp(this);
            end
        end
    end
end

