import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import DashboardLayout from "@/components/DashboardLayout";
import { useToast } from "@/hooks/use-toast";
import { Users as UsersIcon } from "lucide-react";
import { DataTable, type Column } from "@/components/DataTable";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Badge } from "@/components/ui/badge";

interface DirectoryUser {
  id: string;
  aad_id: string | null;
  display_name: string | null;
  email: string | null;
  user_principal_name: string | null;
  job_title: string | null;
  department: string | null;
  account_enabled: boolean | null;
  created_at: string;
  updated_at: string;
}

const Users = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [users, setUsers] = useState<DirectoryUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState<DirectoryUser | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);

  useEffect(() => {
    checkAccess();
    fetchUsers();
  }, [navigate]);

  const checkAccess = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      navigate("/auth");
      return;
    }

    const { data } = await supabase
      .from("user_roles")
      .select("role")
      .eq("user_id", session.user.id)
      .in("role", ["admin", "support_staff"])
      .maybeSingle();

    if (!data) {
      toast({
        title: "Access Denied",
        description: "You must be an admin or support staff to access this page",
        variant: "destructive",
      });
      navigate("/dashboard");
    }
  };

  const fetchUsers = async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from("directory_users")
      .select("*")
      .order("display_name");

    if (error) {
      toast({
        title: "Error",
        description: "Failed to fetch users from directory",
        variant: "destructive",
      });
    } else {
      setUsers(data || []);
    }
    setLoading(false);
  };

  const handleRowClick = (user: DirectoryUser) => {
    setSelectedUser(user);
    setSheetOpen(true);
  };

  const columns: Column<DirectoryUser>[] = [
    {
      key: "display_name",
      label: "Name",
      sortable: true,
      filterPlaceholder: "Filter by name...",
    },
    {
      key: "email",
      label: "Email",
      sortable: true,
      filterPlaceholder: "Filter by email...",
    },
    {
      key: "job_title",
      label: "Job Title",
      sortable: true,
      filterPlaceholder: "Filter by job title...",
    },
    {
      key: "department",
      label: "Department",
      sortable: true,
      filterPlaceholder: "Filter by department...",
    },
    {
      key: "account_enabled",
      label: "Status",
      sortable: true,
      render: (user) => (
        <Badge variant={user.account_enabled ? "default" : "secondary"}>
          {user.account_enabled ? "Active" : "Inactive"}
        </Badge>
      ),
    },
  ];

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold flex items-center gap-2">
              <UsersIcon className="w-8 h-8" />
              Microsoft 365 Users
            </h1>
            <p className="text-muted-foreground">View all active users from Microsoft 365</p>
          </div>
        </div>

        {loading ? (
          <p>Loading users...</p>
        ) : (
          <DataTable
            data={users}
            columns={columns}
            onRowClick={handleRowClick}
            searchKeys={["display_name", "email", "job_title", "department"]}
          />
        )}

        <Sheet open={sheetOpen} onOpenChange={setSheetOpen}>
          <SheetContent className="overflow-y-auto">
            <SheetHeader>
              <SheetTitle>User Details</SheetTitle>
              <SheetDescription>
                Information from Microsoft 365 directory
              </SheetDescription>
            </SheetHeader>

            {selectedUser && (
              <div className="space-y-6 mt-6">
                <div className="space-y-2">
                  <label className="text-sm font-medium">Display Name</label>
                  <p className="text-sm text-muted-foreground">
                    {selectedUser.display_name || "N/A"}
                  </p>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium">Email</label>
                  <p className="text-sm text-muted-foreground">
                    {selectedUser.email || "N/A"}
                  </p>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium">User Principal Name</label>
                  <p className="text-sm text-muted-foreground">
                    {selectedUser.user_principal_name || "N/A"}
                  </p>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium">Job Title</label>
                  <p className="text-sm text-muted-foreground">
                    {selectedUser.job_title || "N/A"}
                  </p>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium">Department</label>
                  <p className="text-sm text-muted-foreground">
                    {selectedUser.department || "N/A"}
                  </p>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium">Account Status</label>
                  <div>
                    <Badge variant={selectedUser.account_enabled ? "default" : "secondary"}>
                      {selectedUser.account_enabled ? "Active" : "Inactive"}
                    </Badge>
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium">Azure AD ID</label>
                  <p className="text-sm text-muted-foreground font-mono break-all">
                    {selectedUser.aad_id || "N/A"}
                  </p>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium">Last Synced</label>
                  <p className="text-sm text-muted-foreground">
                    {new Date(selectedUser.updated_at).toLocaleString()}
                  </p>
                </div>
              </div>
            )}
          </SheetContent>
        </Sheet>
      </div>
    </DashboardLayout>
  );
};

export default Users;
