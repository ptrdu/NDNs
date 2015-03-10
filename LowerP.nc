/**
 * this module provides the lowerCtp interface
 * ,implements the command in the interface.
 * @author ptrdu
 * @date 2014-12-19
 */
module LowerP {
	provides {
		interface lowerCtp;
	}
	uses {
		interface StdControl as RoutControl;
		interface RootControl;
		interface CtpInfo;
	}
}
implementation {
	uint16_t parent;//the parent node 

	command uint16_t lowerCtp.getParent() {
		// get the node's parent node in the tree
		call CtpInfo.getParent(&parent);
		return parent;
	}

	command void lowerCtp.setRoot(uint16_t rootId) {
		// set the root of the network tree
		if(TOS_NODE_ID == rootId) {
			call RootControl.setRoot();
			dbg("CTP","The root node in the network!\n");
		}
		else {
			call RootControl.unsetRoot();
		}
	}

	command error_t lowerCtp.ctpStart() {
		// TODO Auto-generated method stub
		dbg("CTP","The CTP protocol start!\n");
		return call RoutControl.start();
	}
}